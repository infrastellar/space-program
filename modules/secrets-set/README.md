# MODULE: secrets-set

This module is used to put a secret into AWS Secrets Manager.

**WARNING:** It should only be used by Terraform resources that are already
storing sensitive state in terraform.tfstate files. Any other secrets managed
external to Terraform should **NOT** use the `var.value` and manual upload
process.

This module works in connection with `secrets-get`.

## Usage

### Storing a secret for something managed by Terraform

```
module "postgres_secrets" {
  source = "./modules/secrets-set"

  namespace = format("%s/secrets/infra", var.env)
  secret    = "postgres"
  value = {
    PGUSER = aws_db_instance.postgres.username
    PGPASSWORD = aws_db_instance.postgres.password
  }
}
```

This will upload the contents of `value` to `<env>/secrets/infra/postgres`.

### Creating a scaffold for externally managed secret value

```
module "my_secrets" {
  source = "./modules/secrets-set"

  namespace = format("%s/secrets/infra", var.env)
  secret    = "my"
}
```
