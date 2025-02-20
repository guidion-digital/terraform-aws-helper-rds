variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_ids" {}
variable "project" {}
variable "stage" {}
variable "application_name" {}
variable "username" {}
variable "rotator_lambda_role_name" {}

module "rds_mysql" {
  source = "../../"

  application_name = var.application_name
  project          = var.project
  stage            = var.stage

  identifier      = "test-db"
  engine          = "mysql"
  multi_az        = false
  purge_on_delete = true

  proxy_settings = {
    enabled = true
  }

  replica_settings = {
    enabled = true
  }

  username                 = var.username
  password_rotation_days   = 1
  rotator_lambda_role_name = var.rotator_lambda_role_name

  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.subnet_ids

  allow_vpc_cidr = true
}
