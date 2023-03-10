# Infrastellar Space Program

This repository represents the development of Infrastellar Systems "Space
Program", a method for managing reliable production infrastructure.

## Space Program

Space Program is the name for the opinionated Terraform setup that Infrastellar
Systems uses to manage infrastructure. It aims to provide platform operators
and developers with a high level system design that builds in advantages to
reliability, ease of collaboration, and change management.

## Glossary

### Space

A space is a remote terraform configuration and an opinionated configuration
for running infrastructure "missions".

Each space is confined to and operates in a single provider region.

A space recognizes a mission to establish infrastructure resources. A space can
have multiple missions though there the missions themselves must do their own
work to avoid conflicting resources.

### Mission

A mission is a "staged" configuration that contains many procedures
for establishing infrastructure using HashiCorp Terraform.

Missions present a single variable interface for managing the staged
configuration.

Missions are nothing more than an on-disk layout of terraform modules and
components, using an opinionated structure for managing state between
resources.

### Stage

A stage is one layer of a mission. Stages are run in series. All procedures in
a stage can be run in parallel.

Stages represent a directed graph of the mission resources and are established
to build a reliable terraform configuration that is secure and easy to
collaborate around.

### Procedure

A procedure is a terraform module/component. It contains a logical set of
resources that should be configured together. Each procedure has it's own state
file.

### Remote

Remotes are Terraform remote backend configurations for managing Terraform
state. One remote is established for each space.
