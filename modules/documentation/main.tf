# Mission documentation is picked up and suffixed to procedure documentation
# A single empty line is placed at the top of this document to allow proper
# formatting for procedures.
locals {
  doc_abspath_list = split("/", abspath(var.module_path))
  doc_root         = format("../../../../environments/%s/docs/%s", var.environment.name, var.region.id)
  doc_stagename    = flatten(slice(local.doc_abspath_list, length(local.doc_abspath_list) - 2, length(local.doc_abspath_list) - 1))[0]
  doc_procname     = element(local.doc_abspath_list, length(local.doc_abspath_list) - 1)
  doc_mission = {
    root   = format("%s/missions/%s", local.doc_root, var.mission.name)
    readme = format("%s/missions/%s/README.md", local.doc_root, var.mission.name),
  }
  doc_procedure = {
    root   = format("%s/%s/%s", local.doc_mission.root, local.doc_stagename, local.doc_procname),
    readme = format("%s/%s/%s/README.md", local.doc_mission.root, local.doc_stagename, local.doc_procname),
  }
  mission_documentation = templatefile(
    format("../../README.md"), {
      mission_defaults = var.mission_defaults,
      mission_features = var.mission_features,
    }
  )
  procedure_documentation = fileexists("${var.module_path}/README.md") ? templatefile(
    "${var.module_path}/README.md", {
      enable        = var.enable,
      documentation = var.documentation,
      environment   = var.environment,
      mission       = var.mission,
      features      = var.features,
      region        = var.region,
    }
  ) : ""

  generate = alltrue([var.enable.is_publisher, local.procedure_documentation != ""])
}

# Write environments/ENV/docs/missions/MISSION/README.md
resource "local_file" "mission_readme" {
  count    = local.generate ? 1 : 0
  content  = local.mission_documentation
  filename = local.doc_mission.readme
}

# Write environments/ENV/docs/missions/MISSION/STAGE/PROCEDURE/README.md
resource "local_file" "procedure_readme" {
  count    = local.generate ? 1 : 0
  content  = local.procedure_documentation
  filename = local.doc_procedure.readme
}
