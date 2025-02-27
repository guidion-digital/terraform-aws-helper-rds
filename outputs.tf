output "rds_password_secret_arn" {
  description = "ARN of the RDS password secret"
  value       = module.rds_password_secret.arns[local.secret_name]
}

output "rds_password_secret_name" {
  description = "Name of the RDS password secret"
  value       = local.secret_name
}

output "mysql_instance_address" {
  description = "Address of the RDS MySQL instance"
  value       = try(module.rds_mysql[0].db_instance_address, null)
}

output "mysql_instance_name" {
  description = "Name of the RDS MySQL instance"
  value       = try(module.rds_mysql[0].db_instance_name, null)
}

output "mysql_replica_instance_address" {
  description = "Address of the RDS MySQL replica instance"
  value       = try(module.rds_mysql_replica[0].db_instance_address, null)
}

output "mysql_replica_instance_name" {
  description = "Name of the RDS MySQL replica instance"
  value       = try(module.rds_mysql_replica[0].db_instance_name, null)
}

output "mysql_proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = try(module.mysql_rds_proxy[0].proxy_arn, null)
}

output "mysql_proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = try(module.mysql_rds_proxy[0].proxy_endpoint, null)
}

output "mysql_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = try(module.mysql_rds_proxy[0].db_proxy_endpoints, null)
}

output "mysql_db_name" {
  description = "Name of the database"
  value       = local.db_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  proxy_arn_split = try(split(":", module.mysql_rds_proxy[0].proxy_arn), null)
  proxy_real_id   = try(local.proxy_arn_split[length(local.proxy_arn_split) - 1], null)
  proxy_user_arn  = try("arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${local.proxy_real_id}/*", null)
}

output "mysql_proxy_user_arn" {
  description = "ARN for the proxy user"
  value       = local.proxy_user_arn
}
