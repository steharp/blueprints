module "resource_group_shared_egress" {
  source  = "aztfmod/caf-resource-group/azurerm"
  version = "0.1"

  prefix          = var.prefix
  resource_groups = var.resource_groups_shared_egress
  tags            = var.tags
}

module "networking_shared_egress_vnet" {
  source  = "aztfmod/caf-virtual-network/azurerm"
  version = "0.1.0"
    
  virtual_network_rg                = module.resource_group_shared_egress.names["HUB-EGRESS-NET"]
  prefix                            = var.prefix
  location                          = var.location["region1"]
  networking_object                 = var.networking_object
  tags                              = var.tags
  diagnostics_map                   = var.diagnostics_map
  log_analytics_workspace           = var.log_analytics_workspace
}

module "networking_shared_public_ip" {
  source  = "aztfmod/caf-public-ip/azurerm"
  version = "0.1.1"

  name                             = var.ip_name
  location                         = var.location["region1"]
  rg                               = module.resource_group_shared_egress.names["HUB-EGRESS-NET"]
  ip_addr                          = var.ip_addr
  tags                             = var.tags
  diagnostics_map                  = var.diagnostics_map
  log_analytics_workspace_id       = var.log_analytics_workspace.id
  diagnostics_settings             = var.ip_diags
}

module "networking_shared_egress_azfirewall" {
  source  = "aztfmod/caf-azure-firewall/azurerm"
  version = "0.1.0"

  az_fw_name                        = var.az_fw_name
  az_fw_rg                          = module.resource_group_shared_egress.names["HUB-EGRESS-NET"]
  subnet_id                         = module.networking_shared_egress_vnet.vnet_subnets["AzureFirewallSubnet"]
  public_ip_id                      = module.networking_shared_public_ip.id
  location                          = var.location["region1"]
  tags                              = var.tags
  diagnostics_map                   = var.diagnostics_map
  log_analytics_workspace_id        = var.log_analytics_workspace.id
  diagnostics_settings              = var.fw_diags
}

module "firewall_rules" {
  source = "./az_firewall_rules"
  
  az_firewall_settings                 = module.networking_shared_egress_azfirewall.az_firewall_config
}

module "user_route_egress_to_az_firewall" {
  source = "git://github.com/aztfmod/route_table.git?ref=v0.2"

  route_name                        = var.udr_route_name
  route_resource_group              = module.resource_group_shared_egress.names["HUB-EGRESS-NET"]
  location                          = var.location["region1"]
  route_prefix                      = var.udr_prefix
  route_nexthop_type                = var.udr_nexthop_type
  route_nexthop_ip                  = module.networking_shared_egress_azfirewall.az_firewall_config.az_ipconfig[0].private_ip_address
  tags                              = var.tags
}

resource "azurerm_virtual_network_peering" "peering_shared_services_to_egress" {
  depends_on                    = [ module.networking_shared_egress_vnet ]

  name                          = "shared_services_to_egress"
  resource_group_name           = var.virtual_network_rg.names["HUB-CORE-NET"]
  virtual_network_name          = var.shared_services_vnet_object.vnet_name
  remote_virtual_network_id     = module.networking_shared_egress_vnet.vnet_obj.id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
}

resource "azurerm_virtual_network_peering" "peering_egress_to_shared_services" {
  name                          = "egress_to_shared_services"
  depends_on                    = [ module.networking_shared_egress_vnet ]

  resource_group_name           = module.resource_group_shared_egress.names["HUB-EGRESS-NET"]
  virtual_network_name          = module.networking_shared_egress_vnet.vnet_obj.name
  remote_virtual_network_id     = var.shared_services_vnet_object.vnet_id
  allow_virtual_network_access  = false
  allow_forwarded_traffic       = true
}