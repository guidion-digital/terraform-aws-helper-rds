locals {
  allowed_cidrs = var.allow_vpc_cidr && var.vpc_cidr != null ? concat([var.vpc_cidr], var.allowed_cidrs) : var.allowed_cidrs
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-${var.engine}-rds"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  tags = local.tags.tags
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
  for_each = toset(local.allowed_cidrs)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  from_port         = var.port
  ip_protocol       = "tcp"
  to_port           = var.port
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv6" {
  security_group_id = aws_security_group.this.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

locals {
  vpc_security_group_ids = concat([aws_security_group.this.id], var.vpc_security_group_ids)
}
