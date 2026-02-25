# MODULE: reference

This module is used to reference another state file and retrieve it's outputs.

This module works in conjuction with the Space Program configuration, with
missions, stages, and procedures.

## Requirements

An AWS account id must be set in variables to make finding state easier and to
avoid duplication in passing it as a variable (though that is fine as well).

## Usage

```
module "procedure" {
  source    = "../../modules/reference"
  mission   = mission
  stage     = stage
  procedure = procedure
}
```

For example, to retrieve the VPC configuration in the `ci` mission at stage
`stage000` with the procedure named `vpc-pub`:

```
module "vpc_pub" {
  source    = "../../modules/reference"
  mission   = "ci"
  stage     = "stage000"
  procedure = "vpc-pub"
}
```

In this case the `vpc-pub` procedure had the following output defined:

```
outputs "vpc" {
  value = aws_vpc.vpc
}
```

After using this `reference` module, you can retrieve attributes on this output
like so:

```
module.vpc_pub.state.vpc.id
```
