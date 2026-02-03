variable "application_name" {
  description = "Name of the application these resources are tied to"
  type        = string
}

variable "project" {
  description = "Company project (team) responsible for these resources"
  type        = string
}

variable "stage" {
  description = "Used for tagging. e.g. staging, production, etc."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "allocated_storage" {
  description = "The amount of storage (in GB) to allocate for the RDS instance"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The maximum amount of storage (in GB) to allocate for the RDS instance"
  type        = number
  default     = 120
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "The daily time range (in UTC) during which automated backups are created if automated backups are enabled, using the BackupRetentionPeriod parameter"
  type        = string
  default     = "sun:03:34-sun:04:04"
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if automated backups are enabled, using the BackupRetentionPeriod parameter"
  type        = string
  default     = "04:18-04:48"
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Specifies whether the DB instance can be deleted"
  type        = bool
  default     = true
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the creation of a final snapshot"
  type        = bool
  default     = false
}

variable "purge_on_delete" {
  description = "If true, all snapshots and backups will be deleted on DB deletion, and deletion protection will be turned off. This needs to be true if you want to delete the DB(s) _before_ you attempt a destroy"
  type        = bool
  default     = false
}

locals {
  deletion_protection      = var.purge_on_delete ? false : var.deletion_protection
  delete_automated_backups = var.purge_on_delete ? true : var.delete_automated_backups
  skip_final_snapshot      = var.purge_on_delete ? true : var.skip_final_snapshot
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "The availability zone of the RDS instance"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Specifies if the DB instance is a Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "blue_green_update" {
  description = "Maintain blue/green instances for manual failover (for example, during major version upgrades)"
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "options" {
  description = "A list of Options to apply. Creates a DB option group if supplied"

  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))

  default = []
}

variable "allowed_cidrs" {
  description = "List of CIDRs to allow inbound traffic from"
  type        = list(string)
  default     = []
}

variable "allow_vpc_cidr" {
  description = "Whether to allow the VPC CIDR"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the DB instance"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the DB instance. Amended to the security group this module creates from var.allowed_cidrs"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the DB instance. Needed if create_db_subnet_group is true"
  type        = list(string)
  default     = []
}

variable "create_db_subnet_group" {
  description = "Necessary if there are no default subnets"
  type        = bool
  default     = true
}

variable "create_db_parameter_group" {
  description = "Create a database parameter group"
  type        = bool
  default     = true
}

variable "create_monitoring_role" {
  description = "Create a monitoring role"
  type        = bool
  default     = false
}

variable "username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "password" {
  description = "Password for the RDS instance. Random password will be generated if this variable has no value"
  type        = string
  default     = null
}

variable "password_rotation_days" {
  description = "THIS IS A WORK IN PROGRESS AND SHOULD NOT BE USED. DO NOT SET — Number of days between automatic master user password rotations"
  type        = number
  default     = null
}

variable "password_rotation_duration" {
  description = "The length of the rotation window in hours"
  type        = string
  default     = "3h"
}

variable "rotate_password_immediately" {
  description = "Rotate the password immediately"
  type        = bool
  default     = false
}

variable "rotator_lambda_role_name" {
  description = "The name of the IAM role for the rotator lambda"
  type        = string
  default     = null
}

variable "password_rotation_schedule_expression" {
  description = "AWS Schedule Expression for when the master user password rotation should occur"
  type        = string
  default     = null
}

variable "build_lambdas_in_docker" {
  description = "Whether to build all Lambdas in Docker"
  type        = bool

  default = false
}

variable "grafana_promtail_lambda_arn" {
  description = "ARN of Lambda that will forward on logs to Grafana"
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM database authentication is enabled"
  type        = bool
  default     = false
}

variable "password_kms_key_id" {
  description = "The KMS key ID to use for the RDS instance password"
  type        = string
  default     = null
}

variable "identifier" {
  description = "The name of the RDS instance"
}

variable "db_name" {
  description = "The name of the database to create. If not provided and var.create_db has not explicitly been set to false, var.identifier is used"
  type        = string
  default     = null

  validation {
    condition     = var.db_name == null || can(regex("^[a-z0-9_]+$", var.db_name))
    error_message = "The db_name must contain only lowercase letters, numbers, and underscores."
  }
}

variable "create_db" {
  description = "Whether to create a DB on the instance"
  type        = bool
  default     = true
}

locals {
  raw_db_name = var.db_name == null && var.create_db ? var.identifier : var.db_name
  db_name     = replace(local.raw_db_name, "-", "_")
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values: alert, audit, error, general, listener, slowquery, trace"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "The database engine to use. Only MySQL is supported at the moment"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = null
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "mysql8.0"
}

variable "major_engine_version" {
  description = "The major engine version to use"
  type        = string
  default     = "8.0"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 3306
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.t3.micro"
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "timeouts_create" {
  description = "The timeout for the create operation"
  type        = string
  default     = "40m"
}

variable "timeouts_delete" {
  description = "The timeout for the delete operation"
  type        = string
  default     = "40m"
}

variable "timeouts_update" {
  description = "The timeout for the update operation"
  type        = string
  default     = "80m"
}

variable "storage_type" {
  description = "The type of storage to use for the DB instance (e.g., gp2, gp3, io1)"
  type        = string
  default     = "gp2"

  validation {
    condition     = var.storage_type == "gp2" || var.storage_type == "gp3" || var.storage_type == "io1"
    error_message = "The storage_type must be one of: gp2, gp3, io1"
  }
}

variable "storage_throughput" {
  description = "The storage throughput value for the DB instance (only valid for gp3 storage type)"
  type        = number
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS for the DB instance"
  type        = number
  default     = null
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for storage encryption"
  type        = string
  default     = null
}

variable "engine_lifecycle_support" {
  description = "Indicates if the DB instance should have lifecycle support"
  type        = bool
  default     = null
}

variable "publicly_accessible" {
  description = "Determines if the DB instance is publicly accessible"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "network_type" {
  description = "The type of network to use for the DB instance"
  type        = string
  default     = null
}

variable "proxy_settings" {
  description = "Settings for RDS proxy configuration"
  type = object({
    enabled                        = optional(bool, true)                            # Whether to enable the proxy
    require_tls                    = optional(bool, true)                            # Whether to require TLS for the proxy
    idle_client_timeout            = optional(number, 1800)                          # The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it
    iam_role_name                  = optional(string, null)                          # Name of the IAM role that the proxy uses to access secrets in AWS Secrets Manager
    role_arn                       = optional(string, "")                            # ARN of the IAM role that the proxy uses to access secrets in AWS Secrets Manager
    create_iam_policy              = optional(bool, false)                           # Whether to create an IAM policy for the proxy
    create_iam_role                = optional(bool, false)                           # Whether to create an IAM role for the proxy
    connection_borrow_timeout      = optional(number, null)                          # Number of seconds for a proxy to wait for a connection to become available in the connection pool
    init_query                     = optional(string, "")                            # One or more SQL statements for the proxy to run when opening each new database connection
    max_connections_percent        = optional(number, 90)                            # The maximum size of the connection pool for each target in a target group
    max_idle_connections_percent   = optional(number, 10)                            # The maximum size of the idle connection pool for each target in a target group
    session_pinning_filters        = optional(list(string), [])                      # A list of session pinning filters
    iam_auth                       = optional(string, "DISABLED")                    # No IAM auth by default
    auth_client_password_auth_type = optional(string, "MYSQL_CACHING_SHA2_PASSWORD") # The type of authentication the proxy uses for connections from clients. 
    auth_scheme                    = optional(string, "SECRETS")                     # The type of authentication that the proxy uses for connections from the proxy to the underlying database.
  })

  default = {
    enabled = false
  }
}

variable "replica_settings" {
  description = "Settings for RDS replica configuration"
  type = object({
    enabled                               = optional(bool, true)
    instance_class                        = optional(string)
    availability_zone                     = optional(string)
    publicly_accessible                   = optional(bool)
    vpc_security_group_ids                = optional(list(string))
    allow_major_version_upgrade           = optional(bool)
    auto_minor_version_upgrade            = optional(bool)
    maintenance_window                    = optional(string)
    max_allocated_storage                 = optional(number)
    storage_throughput                    = optional(number)
    performance_insights_enabled          = optional(bool)
    performance_insights_retention_period = optional(number)
    apply_immediately                     = optional(bool)
    ca_cert_identifier                    = optional(string)
    network_type                          = optional(string)
    create_db_subnet_group                = optional(bool, true)
    subnet_ids                            = optional(list(string))
    enabled_cloudwatch_logs_exports       = optional(list(string))
    timeouts_create                       = optional(string)
    timeouts_delete                       = optional(string)
    timeouts_update                       = optional(string)
    create_db_parameter_group             = optional(bool, false)

    options = optional(list(object({
      option_name = string
      option_settings = list(object({
        name  = string
        value = string
      }))
    })))
  })

  default = {
    enabled = false
  }
}

locals {
  replica_options = var.replica_settings.options == null ? var.options : var.replica_settings.options
}
