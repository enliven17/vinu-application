resource "aws_ecr_repository" "frontend" {
  name                 = "vinu-task2-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "backend" {
  name                 = "vinu-task2-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
