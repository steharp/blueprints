module "resource_group_shared_services" {
  source  = "aztfmod/caf-resource-group/azurerm"
  version = "0.1"

  prefix          = var.prefix
  resource_groups = var.resource_groups_shared_services
  tags            = var.tags
}

module "networking_shared_services" {
  source  = "aztfmod/caf-virtual-network/azurerm"
  version = "0.1.0"

  virtual_network_rg                = module.resource_group_shared_services.names["HUB-CORE-NET"]
  prefix                            = var.prefix
  location                          = var.location["region1"]
  networking_object                 = var.shared_services_vnet
  tags                              = var.tags
  diagnostics_map                   = var.diagnostics_map
  log_analytics_workspace           = var.log_analytics_workspace
}

module "ddos_protection_std" {
  source = "./ddos_protection"

  enable_ddos_standard              = var.enable_ddos_standard
  name                              = var.ddos_name
  rg                                = module.resource_group_shared_services.names["HUB-CORE-NET"]
  location                          = var.location["region1"] 
  tags                              = var.tags
}

# module "network_monitoring_shared_services" {
#   source = "./network_monitoring"
  
#   computer_name                     = "netmon-sharedsvc"
#   rg                                = data.terraform_remote_state.tranquility_tfstate.outputs.resource_group_hub_names["HUB-CORE-NET"]
#   location                          = data.terraform_remote_state.tranquility_tfstate.outputs.location_map["region1"] 
#   subnet_id                         = module.networking_shared_services.vnet_subnets["Network_Monitoring"]
#   tags                              = data.terraform_remote_state.tranquility_tfstate.outputs.tags_hub
#   diagnostics_map                   = data.terraform_remote_state.tranquility_tfstate.outputs.diagnostics_map
#   log_analytics_workspace_object    = data.terraform_remote_state.tranquility_tfstate.outputs.log_analytics_workspace_object
#   akv_key_repos                     = data.terraform_remote_state.tranquility_tfstate.outputs.akv_object
# }