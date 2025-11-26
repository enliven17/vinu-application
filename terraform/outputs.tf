output "instance_ip" {
  value = aws_instance.app_server.public_ip
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "verifier_iam_user_name" {
  value = aws_iam_user.verifier.name
  description = "IAM user name for verification"
}

output "verifier_access_key" {
  value = aws_iam_access_key.verifier.id
  description = "IAM access key ID for verification"
}

output "verifier_secret_key" {
  value     = aws_iam_access_key.verifier.secret
  sensitive = true
  description = "IAM secret access key for verification (sensitive)"
}

output "generated_private_key_pem" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}
