#Deploy the extension  - https://docs.microsoft.com/en-gb/azure/virtual-machines/extensions/oms-linux

resource "azurerm_virtual_machine_extension" "log_analytics_linux" {
  # depends_on           = [azurerm_virtual_machine_extension.network_watcher_linux]
  
  name                 = "vm_log_analytics_linux"
  location             = var.location
  resource_group_name  = var.rg
  virtual_machine_name = azurerm_virtual_machine.netmonbox.name
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.11"

  settings = <<SETTINGS
    {
      "autoUpgradeMinorVersion": "true",
      "workspaceId": "${var.log_analytics_workspace_object.workspace_id}"
    }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_object.primary_shared_key}"
    }
    PROTECTED_SETTINGS
  

  tags = var.tags
}