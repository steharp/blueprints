module "blueprint_tranquility" {
    source                              = "../blueprint_tranquility"

    prefix                              = local.prefix

    location_map                        = var.location_map
    security_center                     = var.security_center
    azure_activity_logs_retention       = var.azure_activity_logs_retention
    azure_diagnostics_logs_retention    = var.azure_diagnostics_logs_retention
    resource_groups_hub                 = var.resource_groups_hub
    tags_hub                            = var.tags_hub
    solution_plan_map                   = var.solution_plan_map
}
