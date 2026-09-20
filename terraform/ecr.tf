# ECR Repository for Vote service using AWS Community Module
module "ecr_vote" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  repository_name                 = "${var.app_name}-vote"
  repository_image_tag_mutability = "MUTABLE"
  repository_force_delete         = true

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images for cost optimization"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-vote"
  }
}

# ECR Repository for Result service using AWS Community Module
module "ecr_result" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  repository_name                 = "${var.app_name}-result"
  repository_image_tag_mutability = "MUTABLE"
  repository_force_delete         = true

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images for cost optimization"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-result"
  }
}

# ECR Repository for Worker service using AWS Community Module
module "ecr_worker" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  repository_name                 = "${var.app_name}-worker"
  repository_image_tag_mutability = "MUTABLE"
  repository_force_delete         = true

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images for cost optimization"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-worker"
  }
}
