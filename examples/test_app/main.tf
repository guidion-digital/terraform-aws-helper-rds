variable "project" { default = "constr" }
variable "stage" { default = "localstack" }
variable "application_name" { default = "foobar" }

module "rds_mysql" {
  source = "../../"

  application_name = var.application_name
  project          = var.project
  stage            = var.stage

  additional_tags = {
    "extra" = "spicey"
  }

  identifier      = "test-db"
  engine          = "mysql"
  multi_az        = false
  purge_on_delete = true

  proxy_settings = {
    enabled  = true
    role_arn = aws_iam_role.rds_proxy.arn
  }

  replica_settings = {
    enabled = true
  }

  username = "holden"

  vpc_id     = module.vpc.vpc_attributes.id
  vpc_cidr   = module.vpc.vpc_attributes.cidr_block
  subnet_ids = [for _, value in module.vpc.private_subnet_attributes_by_az : value.id]

  allow_vpc_cidr = true
}
