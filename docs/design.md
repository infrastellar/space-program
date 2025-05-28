# Infrastellar Space Program

This repository represents the development of Infrastellar Systems "Space
Program", a method for managing reliable production infrastructure.

## Space Program

The Space Program is the name for the opinionated setup that Infrastellar
Systems uses to manage infrastructure. It aims to provide platform operators
and developers with a high level system design that builds in advantages to
reliability, ease of collaboration, and change management. The system has
existed in a similar shape and has been developed since 2018 and constitutes
all the lessons learned from running a global production infrastructure for a
large enterprise company down to small companies focused on compliance and
security.

## Narrative

Each feature of the Space Program method for setting up infrastructure is
designed to be easy to communicate. A space is simply that, a space to put
infrastructure configuration. There isn't much more to it. Your mission is then
to fill that space with infrastructure. Missions are designed to achieve some
outcome. Perhaps you want to stand up an entirely new management network with
resources. You can develop a mission around that single idea.

Once you have a mission, you want to reliably execute that mission in the space
you have designated. To do this you will need to do a bit of systems design to
understand how the resources you want to create fit together. Once you have
that understanding you want to break resources down into procedures that are
executed in stages. For example putting procedures in stage000 means that your
procedures have zero dependencies other than the cloud provider. Stage010
procedures have dependencies on those in stage000, stage020 on those in
stage000 and stage010, and so on.

Procedures should be self contained in that they pull in inputs (whether
through variables, other resources, or other procedures), do something with
that data and then produce outputs. While they are self contained in their
configuration they should recognize that they are being executed within a
mission, which provides them with a base configuration in order to do their
work. For tools like Terraform (OpenTofu if that is your preference) this setup
works to their strengths.

## Glossary

### Space

A space is typically a remote terraform configuration and an opinionated
configuration for running infrastructure "missions".

Each space is confined to and operates in a single provider region.

A space recognizes a mission to establish infrastructure resources. A space can
have multiple missions. Missions are responsible for maintaining their own name
space to avoid conflicting resources.

### Mission

A mission is a configuration that contains staged procedures for establishing
infrastructure using tools like terraform. Missions present a single variable
interface for managing the staged configuration.

Missions are nothing more than an on-disk layout of terraform modules and
components, using an opinionated structure for managing state between
resources.

### Stage

A stage is one layer of a mission. Stages are run in series. All procedures in
a stage are run in parallel.

Stages help to establish a directed graph of the mission resources and are
established to build a reliable terraform configuration that is secure and easy
to collaborate on.

### Procedure

A procedure is a terraform module/component. It contains a logical set of
resources that should be configured together. Each procedure has it's own state
file.

### Remote

Remotes are Terraform remote backend configurations for managing Terraform
state. A space is a remote configuration.
