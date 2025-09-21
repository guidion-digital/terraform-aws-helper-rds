module "these_tags" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = var.project
  name      = var.identifier
  delimiter = "-"

  tags = {
    "Terraform"   = "true",
    "Module"      = "helper-rds",
    "project"     = var.project,
    "application" = var.application_name,
    "stage"       = var.stage
  }
}

locals {
  tags = merge(var.additional_tags, module.these_tags.tags)
}

module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  count = var.engine == "mysql" ? 1 : 0

  identifier = var.identifier

  db_name                     = local.db_name
  engine                      = "mysql"
  engine_version              = var.engine_version
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  family                      = var.family
  major_engine_version        = var.major_engine_version
  ca_cert_identifier          = var.ca_cert_identifier
  port                        = var.port

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_throughput    = var.storage_throughput
  iops                  = var.iops
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  engine_lifecycle_support              = var.engine_lifecycle_support
  publicly_accessible                   = var.publicly_accessible
  apply_immediately                     = var.apply_immediately
  multi_az                              = var.multi_az
  blue_green_update                     = { enabled = var.blue_green_update }
  skip_final_snapshot                   = local.skip_final_snapshot
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  delete_automated_backups              = local.delete_automated_backups
  network_type                          = var.network_type

  username                            = var.username
  manage_master_user_password         = false
  password                            = local.password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  create_db_option_group       = length(var.options) > 0 ? true : false
  option_group_name            = length(var.options) > 0 ? "${var.identifier}-${var.engine}" : null
  option_group_description     = "For ${var.identifier}-${var.engine}"
  option_group_use_name_prefix = false
  options                      = var.options

  create_db_parameter_group = var.create_db_parameter_group

  vpc_security_group_ids = local.vpc_security_group_ids
  subnet_ids             = var.replica_settings.subnet_ids == null ? var.subnet_ids : var.replica_settings.subnet_ids
  create_db_subnet_group = var.replica_settings.create_db_subnet_group

  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  deletion_protection     = local.deletion_protection

  timeouts = {
    create = var.timeouts_create
    delete = var.timeouts_delete
    update = var.timeouts_update
  }

  db_instance_tags = local.tags
  tags             = local.tags
}

module "rds_mysql_replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  count = var.engine == "mysql" && var.replica_settings.enabled ? 1 : 0

  identifier          = "${var.identifier}-replica"
  replicate_source_db = module.rds_mysql[0].db_instance_arn

  engine               = "mysql"
  engine_version       = var.engine_version
  family               = var.family
  major_engine_version = var.major_engine_version
  ca_cert_identifier   = var.replica_settings.ca_cert_identifier == null ? var.ca_cert_identifier : var.replica_settings.ca_cert_identifier
  port                 = var.port

  instance_class        = var.replica_settings.instance_class == null ? var.instance_class : var.replica_settings.instance_class
  max_allocated_storage = var.replica_settings.max_allocated_storage == null ? var.max_allocated_storage : var.replica_settings.max_allocated_storage
  storage_type          = var.storage_type
  storage_throughput    = var.replica_settings.storage_throughput == null ? var.storage_throughput : var.replica_settings.storage_throughput
  iops                  = var.iops
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  engine_lifecycle_support              = var.engine_lifecycle_support
  publicly_accessible                   = var.replica_settings.publicly_accessible == null ? var.publicly_accessible : var.replica_settings.publicly_accessible
  apply_immediately                     = var.replica_settings.apply_immediately == null ? var.apply_immediately : var.replica_settings.apply_immediately
  multi_az                              = false
  skip_final_snapshot                   = true
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  performance_insights_enabled          = var.replica_settings.performance_insights_enabled == null ? var.performance_insights_enabled : var.replica_settings.performance_insights_enabled
  performance_insights_retention_period = var.replica_settings.performance_insights_retention_period == null ? var.performance_insights_retention_period : var.replica_settings.performance_insights_retention_period
  delete_automated_backups              = local.delete_automated_backups
  network_type                          = var.replica_settings.network_type == null ? var.network_type : var.replica_settings.network_type

  create_db_option_group       = length(local.replica_options) > 0 ? true : false
  option_group_name            = length(local.replica_options) > 0 ? "${var.identifier}-${var.engine}-replica" : null
  option_group_description     = "For ${var.identifier}-${var.engine}-replica"
  option_group_use_name_prefix = false
  options                      = local.replica_options
  create_db_parameter_group    = var.replica_settings.create_db_parameter_group

  username                            = var.username
  manage_master_user_password         = false
  password                            = local.password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.replica_settings.vpc_security_group_ids == null ? local.vpc_security_group_ids : var.replica_settings.vpc_security_group_ids
  subnet_ids             = var.replica_settings.subnet_ids == null ? var.subnet_ids : var.replica_settings.subnet_ids
  create_db_subnet_group = var.create_db_subnet_group

  maintenance_window      = var.maintenance_window
  backup_retention_period = 0
  deletion_protection     = false

  timeouts = {
    create = var.replica_settings.timeouts_create == null ? var.timeouts_create : var.replica_settings.timeouts_create
    delete = var.replica_settings.timeouts_delete == null ? var.timeouts_delete : var.replica_settings.timeouts_delete
    update = var.replica_settings.timeouts_update == null ? var.timeouts_update : var.replica_settings.timeouts_update
  }

  db_instance_tags = local.tags
  tags             = local.tags
}

module "mysql_rds_proxy" {
  source  = "terraform-aws-modules/rds-proxy/aws"
  version = "v3.2.1"

  depends_on = [module.rds_mysql]

  count = var.engine == "mysql" && var.proxy_settings.enabled ? 1 : 0

  name                   = var.identifier
  engine_family          = upper(var.engine)
  target_db_instance     = true
  db_instance_identifier = var.identifier

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = local.vpc_security_group_ids
  require_tls            = var.proxy_settings.require_tls

  iam_role_name     = var.proxy_settings.iam_role_name != null ? "${var.identifier}-proxy-role" : null
  create_iam_policy = var.proxy_settings.create_iam_policy
  create_iam_role   = var.proxy_settings.create_iam_role

  endpoints = {
    read_write = {
      name                   = "${var.identifier}-read-write"
      vpc_subnet_ids         = var.subnet_ids
      vpc_security_group_ids = local.vpc_security_group_ids
      target_role            = "READ_WRITE"
    }
  }

  auth = {
    "superuser" = {
      description = "RDS password for ${var.identifier}"
      secret_arn  = module.rds_password_secret.arns[local.secret_name]
      iam_auth    = var.proxy_settings.iam_auth
    }
  }

  idle_client_timeout          = var.proxy_settings.idle_client_timeout
  role_arn                     = var.proxy_settings.role_arn
  connection_borrow_timeout    = var.proxy_settings.connection_borrow_timeout
  init_query                   = var.proxy_settings.init_query
  max_connections_percent      = var.proxy_settings.max_connections_percent
  max_idle_connections_percent = var.proxy_settings.max_idle_connections_percent
  session_pinning_filters      = var.proxy_settings.session_pinning_filters

  proxy_tags = local.tags
  tags       = local.tags
}
