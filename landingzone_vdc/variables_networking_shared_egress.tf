
variable "networking_egress" {
    description = "Networking object for the egress"
}

variable "virtual_network_rg" {
  description = "(Required) Map of the resource groups to create"
  default     = ""
}

variable "location" {
  description = "(Required) Define the region where the resource groups will be created"
  default = ""
}

variable "tags" {
  description = "tags for the deployment"
  default = []
}

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

variable "ip_addr" {
  
}

variable "ddos_name" {
  
}

variable "enable_ddos_standard" {
  
}

variable "ip_addr_diags" {
  
}

variable "az_fw_diags" {
  
}

variable "resource_groups_shared_egress" {
  
}

variable "ip_name" {
  
}


