# MODULE: documentation

This module is the main way we manage documentation across the
`space-program`. It takes the READMEs of the procedures that the module runs on
and treats them as templates and places the rendered README.md into the proper
path under the `environments` directory specific to the environment where
plan/apply was run.

## How Missions Use the Module

The "footprint" for using this module is the exact same across all missions
(except glv1 currently). This is declared in the mission file, example:
`missions/MISSIONNAME/MISSIONNAME.tf`.

### Example

```
module "documentation" {
  source      = "../../modules/documentation"
  module_path = path.module

  # Pass in a documentation structure from the procedure if it exists
  documentation = local.documentation

  # The following are passed to the procedure README.md templatefile function
  region      = var.region
  environment = var.environment
  mission     = local.mission  # Compiled from the mission configuration in the environment
  features    = local.features # Compiled from the environment configuration
  enable      = local.enable   # Enabled on the mission according to the environment configuration

  # The following are passed to the mission README.md templatefile function
  mission_defaults = local.mission_defaults # Mission default configurations
  mission_features = local.mission_features # Mission default features
}
```

All variables are of type `any` which allows us to pass in whatever want.

## Procedure Documentation

We look for a map on a procedure named `local.documentation`. This map can have
any keys/values which are then fed into the templates for generating the
procedure README. This allows us to be able to use our configuration to
generate very specific documentation.

Any new procedure must have at least this:

```
locals {
  documentation = {}
}
```

**NOTE:** You can have multiple locals blocks, so you could stuff this at the
end of the `main.tf` and that would be all you would need.

### README

If the procedure contains a README.md it is used as a template but it does not
have to have any template variables. Thankfully `templatefile()` doesn't care
if they are used. However, note the template values within the README.md are
now aligned with those passed into `templatefile()`, so if one passes in
`var.region` to the module, it is passed as `region` to `templatefile()` and
then used in the documentation like `${region.id}`.

## Rendered Documentation

Rendered documents are generated during plan/apply. They will need to be
committed after the apply if there are changes.
