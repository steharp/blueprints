variable "prefix" {
  
}


variable "networking_object" {
  description = "Network configuration"
}

variable "virtual_network_rg" {
  description = "(Required) Map of the resource groups to create"
}

variable "shared_services_vnet_object" {
  
}


variable "location" {
  description = "(Required) Define the region where the resource groups will be created"
}

variable "tags" {
  description = "tags for the deployment"
  default = []
}

variable "ip_addr" {
  description = "tags for the deployment"
}

variable "ip_name" {
  description = "name of the public IP address"
}


# variable "ip_address_dns_prefix" {
#   description = "(Required) DNS prefix for the public IP address to be created"
# }
# variable "ip_address_timeout" {
#   description = "(Required) Timeout used for the public IP address"
# }

# variable "ip_address_zones" {
#   description = "(Required) Zone for the public IP address to be deployed"
# }

# variable "ip_address_allocation_method" {
#   description = "(Required) Allocation method of the IP address to be created"
# }

# variable "ip_address_sku" {
#   description = "(Required) SKU of the IP address to be created"
# }

variable "az_fw_name" {
  description = "(Required) name for the Azure Firewall to be created"
}

variable "udr_prefix" {
  description = "(Required) prefix for the user route table"
}

variable "udr_nexthop_type" {
  description = "(Required) next hop type for the user route table - can be of VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None" 
}

variable "udr_nexthop_ip" {
  description = "(Optional) next hop IP address for the user route table" 
  default = ""
}

variable "udr_route_name" {
  description = "(Required) name for the user route table"  
}

variable "subnets_to_udr" {
  description = "Subnet ID to be added to the user route object"
  default = ""
}

variable "log_analytics_workspace" {
  
}

variable "diagnostics_map" {
  
}

variable "fw_diags" {
  
}

variable "ip_diags" {
  
}

variable "resource_groups_shared_egress" {
  
}
