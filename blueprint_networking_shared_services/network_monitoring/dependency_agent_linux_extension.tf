# #Deploy the extension  - https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-linux

# resource "azurerm_virtual_machine_extension" "dependency_agent_linux" {
#   # depends_on           = [azurerm_virtual_machine_extension.iaas_diagnostics_linux]
  
#   name                 = "vm_dependency_agent_linux"
#   location             = var.location
#   resource_group_name  = var.rg
#   virtual_machine_name = azurerm_virtual_machine.netmonbox.name
#   publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                 = "DependencyAgentLinux"
#   type_handler_version = "9.8"

#   protected_settings = <<SETTINGS
#     {
#       "autoUpgradeMinorVersion": "true"
#     }
#     SETTINGS

#   tags = var.tags
# }