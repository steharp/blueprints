variable "location" {
   description = "Location of the Virtual Machine to use for network watcher" 
}

variable "rg" {
  description = "Resource group of the Virtual Machine to use for network watcher"
}

variable "subnet_id" {
  description = "Subnet of the Virtual Machine to use for network watcher"
}

variable "computer_name" {
  description = "Name of the Virtual Machine to use for network watcher"
  default = "netmon"
}

variable "vm_size" {
  description = "(Optional) Size of the Virtual Machine to use for network watcher"
  default = "Standard_B1ls"
}

variable "tags" {
  description = "Tags of the Virtual Machine to use for network watcher"
}

variable "diagnostics_map" {
  description = "Diagnostics settings of the Virtual Machine to use for network watcher"
}

variable "log_analytics_workspace_object" {
  description = "Log analytics workspace for the Virtual Machine to use for network watcher"
}

variable "akv_key_repos" {
 description = "Azure Key Vault ID for the SSH keys to be generated"
}

