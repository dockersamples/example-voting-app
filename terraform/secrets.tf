# Random Passwords for Valkey and PostgreSQL
resource "random_password" "valkey_password" {
  length  = 16
  special = false
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

# ==========================================
# SECRETS MANAGER FOR VALKEY (Community Module)
# ==========================================
module "secrets_manager_valkey" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.1"

  name                    = "${var.app_name}-valkey-credentials"
  description             = "Valkey RBAC user and password credentials for ${var.app_name}"
  recovery_window_in_days = 0

  secret_string = jsonencode({
    username = var.valkey_username
    password = random_password.valkey_password.result
  })

  tags = {
    Name = "${var.app_name}-valkey-credentials"
  }
}

# ==========================================
# SECRETS MANAGER FOR POSTGRES (Community Module)
# ==========================================
module "secrets_manager_postgres" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.1"

  name                    = "${var.app_name}-postgres-credentials"
  description             = "PostgreSQL credentials for ${var.app_name}"
  recovery_window_in_days = 0

  secret_string = jsonencode({
    username = var.aurora_master_username
    password = random_password.postgres_password.result
  })

  tags = {
    Name = "${var.app_name}-postgres-credentials"
  }
}
