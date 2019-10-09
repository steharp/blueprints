#Deploy the extension  - https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/network-watcher-linux 

resource "azurerm_virtual_machine_extension" "network_watcher_linux" {
  # depends_on           = [azurerm_virtual_machine_extension.log_analytics_linux]

  name                 = "vm_network_watcher_linux"
  location             = var.location
  resource_group_name  = var.rg
  virtual_machine_name = azurerm_virtual_machine.netmonbox.name
  publisher            = "Microsoft.Azure.NetworkWatcher"
  type                 = "NetworkWatcherAgentLinux"
  type_handler_version = "1.4"


  settings = <<SETTINGS
    {
        "autoUpgradeMinorVersion": "true"
    }
SETTINGS

  tags = var.tags
}