# Security Groups

By default, no security rules will be added to the security group that is created and attached to the instance. You can populate the group in the following ways:

- Supplying a list to `var.vpc_security_group_ids`
- Setting `var.allow_vpc_cidr` to `true` (in which case `var.vpc_id` must be provided)
- Supplying a list of values in`var.allowed_cidrs`

Rules are cumulative, so you can use all of the above.

# Replicas and Read-Only Endpoints

A read-only replica can be provided by setting `var.replica_settings.enabled` to `true`. You will then have a value for the `rds_mysql_replica_instance_address` output. Note that read replicas can not be targets for proxies, which is why you will have to use this endpoint to connect to it directly.
