resource "aws_iam_user" "verifier" {
  name = "vinu_task_verifier"
}

resource "aws_iam_access_key" "verifier" {
  user = aws_iam_user.verifier.name
}

resource "aws_iam_user_policy" "verifier_ro" {
  name = "verifier_read_only"
  user = aws_iam_user.verifier.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetConsoleOutput",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
    ]
  })
}

# IAM Role for EC2 instance to access ECR
resource "aws_iam_role" "ec2_role" {
  name = "vinu-task2-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ec2_ecr_policy" {
  name = "vinu-task2-ec2-ecr-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = [
          aws_ecr_repository.frontend.arn,
          aws_ecr_repository.backend.arn
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "vinu-task2-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
