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
  value       = try(module.mysql_rds_proxy[0].arn, null)
}

output "mysql_proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = try(module.mysql_rds_proxy[0].endpoints, null)
}
