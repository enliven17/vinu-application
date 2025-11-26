resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "vinu-task-key-generated"       # Create a unique key name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/vinu-task-key-generated.pem"
  content  = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kp.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get install -y docker.io docker-compose-plugin nginx awscli
              
              # Start and enable Docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              
              # Configure Nginx - Only allow frontend access
              cat > /etc/nginx/sites-available/default <<'EOT'
              server {
                  listen 80;
                  server_name _;
                  
                  # Frontend
                  location / {
                      proxy_pass http://localhost:8080;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }
                  
                  # Backend API (only accessible through frontend)
                  location /api {
                      proxy_pass http://localhost:3000;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }
                  
                  # Block direct access to backend and database ports
                  location ~ ^/(3000|5432) {
                      return 403;
                  }
              }
              EOT
              
              # Enable and restart Nginx
              systemctl enable nginx
              systemctl restart nginx
              
              # Create deployment directory
              mkdir -p /opt/app
              chown ubuntu:ubuntu /opt/app
              
              # Create .env file template for docker-compose
              cat > /opt/app/.env <<EOT
              AWS_ACCOUNT_ID=
              AWS_REGION=us-east-1
              EOT
              chown ubuntu:ubuntu /opt/app/.env
              EOF

  tags = {
    Name = "VinuTask2Server"
  }
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "vinu-task-key" 
}
