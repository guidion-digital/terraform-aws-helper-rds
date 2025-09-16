Part of the [Terrappy framework](https://github.com/guidion-digital/terrappy).

---

# TODO:

- Fix example
- Create workflows for releases

# Usage

See [examples folder](./examples).

## Useful Outputs

- Direct connection: `mysql_instance_address`
- Proxy connection: `proxy_endpoint`
- Read only (enabled with `var.replica_settings.enabled`) direct connection: `mysql_replica_instance_address`
- ARN of secret containing the RDS password: `rds_password_secret_arn`
- Name of the secret containing the RDS password: `rds_password_secret_name`

# Requirements

## WIP: Permissions for Secrets Rotation

> [!WARNING]
> Password rotation is 100% not ready for even testing yet. _Do not set var.password_rotation_days_

Password rotation is enabled by supplying `var.password_rotation_days`, which then depends on `var.rotator_lambda_role_name` also being supplied. This role should contain the following permissions:

The `arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole` policy

The following policy:

```json
{
  "Statement": [
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "rds:DescribeDBInstances" # Needed for the Lambda that will create the additional users
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Condition": {
        "StringEquals": {
          # TODO: Get correct function name
          "secretsmanager:resource/AllowRotationLambdaArn": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:SecretsManagerapp-x-mysql-secret-rotator"
        }
      },
      # TODO: These need to be separated so the resources can be namespaced
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ],
      # TODO: Get correct secret name
      "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "secretsmanager:GetRandomPassword"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
```

# A Note on Secrets and DB Passwords

The reason we don't make use of RDS's own secrets management functionality is that the ASM secret name can not be set. This is a problem because we rely namespacing to hand out access to secrets. We therefore create a rotation Lambda ourselves, if `var.password_rotation_days` is supplied. If rotation is enabled in this way, you must also supply `var.rotator_lambda_role_name`.

# TODO

## Security Groups

### Multiple Users

Create another Lamda if `var.additional_users{}` is non-zero. Map should look like this:

```hcl
variable "additional_users" {
  type = map({
    object({
      user = object({
        database    = string
        tables      = string
        permissions = list(string)
      })
    })
  })
}
```

The Lambda goes through this map and checks to see if those users exist. If yes, then it runs an `ALTER USER` statement, if not then it runs a `CREATE USER` statement.

Two ways to trigger this:

1. Integrate it into the rotation Lambda
1. Separate Lambda that is triggered via EventBridge, by the event of this RDS instance being provisioned
