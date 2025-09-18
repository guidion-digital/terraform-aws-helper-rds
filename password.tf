locals {
  secret_name = "/applications/${var.application_name}/${var.identifier}-rds-password"
}

resource "random_password" "password" {
  count = var.password == null ? 1 : 0

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "rds_password_secret" {
  source  = "guidion-digital/helper-secrets/aws"
  version = "~> 1.0"

  secrets = {
    (local.secret_name) = {
      description                    = "RDS password for ${var.identifier}"
      kms_key_id                     = var.password_kms_key_id
      recovery_window_in_days        = 0
      force_overwrite_replica_secret = false
    }
  }

  tags = local.tags
}

locals {
  password = var.password == null ? random_password.password[0].result : var.password
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = module.rds_password_secret.arns[local.secret_name]
  secret_string = jsonencode({
    username             = var.username
    password             = local.password
    engine               = var.engine
    host                 = module.rds_mysql[0].db_instance_endpoint
    port                 = module.rds_mysql[0].db_instance_port
    dbname               = local.db_name
    dbInstanceIdentifier = module.rds_mysql[0].db_instance_identifier
  })

  lifecycle {
    ignore_changes = [
      secret_string,
      version_stages
    ]
  }
}

# THIS IS A WORK IN PROGRESS AND SHOULD NOT BE USED. DO NOT SET var.password_rotation_days
#
# https://advancedweb.hu/how-to-set-up-amazon-rds-password-rotation-with-terraform/
#
# Peiced together from here:
# https://aws.amazon.com/blogs/security/rotate-amazon-rds-database-credentials-automatically-with-aws-secrets-manager/
# module "rds_mysql_password_rotator_lambda" {
#   count = var.password_rotation_days != null ? 1 : 0
#
#   source  = "app.terraform.io/guidion/app-lambda/aws"
#   version = "0.0.10"
#
#   application_name            = var.application_name
#   stage                       = var.stage
#   project                     = var.project
#   grafana_promtail_lambda_arn = var.grafana_promtail_lambda_arn
#   build_in_docker             = var.build_lambdas_in_docker
#
#   lambdas = {
#     "rds-mysql-password-rotator" = {
#       description = "RDS MySQL Password Rotator"
#       source_dir  = "${path.module}/lambdas/rds-mysql-secret-rotator"
#       runtime     = "python3.11"
#       handler     = "main.handler"
#       lambda_role = var.rotator_lambda_role_name
#
#       rotator_for = {
#         "secretsmanager" = {
#           path = local.secret_name
#         }
#       }
#
#       vpc_subnet_ids         = var.subnet_ids
#       vpc_security_group_ids = local.vpc_security_group_ids
#
#       environment_variables = {
#         EXCLUDE_CHARACTERS         = "/@\"'"
#         EXCLUDE_LOWERCASE          = "false"
#         EXCLUDE_NUMBERS            = "false"
#         EXCLUDE_PUNCTUATION        = "false"
#         EXCLUDE_UPPERCASE          = "false"
#         PASSWORD_LENGTH            = "32"
#         REQUIRE_EACH_INCLUDED_TYPE = "true"
#         SECRETS_MANAGER_ENDPOINT   = "https://secretsmanager.eu-central-1.amazonaws.com"
#       }
#     }
#   }
# }
#
# resource "aws_secretsmanager_secret_rotation" "this" {
#   count = var.password_rotation_days != null ? 1 : 0
#
#   secret_id           = module.rds_password_secret.arns[local.secret_name]
#   rotation_lambda_arn = module.rds_mysql_password_rotator_lambda[0].arns["rds-mysql-password-rotator"]
#   rotate_immediately  = var.rotate_password_immediately
#
#   rotation_rules {
#     automatically_after_days = var.password_rotation_days
#     duration                 = var.password_rotation_duration
#     schedule_expression      = var.password_rotation_schedule_expression
#   }
# }
