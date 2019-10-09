#Deploy the extension  - https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/diagnostics-template
#Check at SAS Token Generation: https://www.terraform.io/docs/providers/azurerm/d/storage_account_sas.html  

locals {
  storagename = basename(var.diagnostics_map.diags_sa)
  storage_rg = split("/", var.diagnostics_map.diags_sa)[4]
}

data "azurerm_storage_account" "ops_sa" {
  name                = local.storagename
  resource_group_name = local.storage_rg
}

data "azurerm_storage_account_sas" "ops_storage_account" {
  connection_string = data.azurerm_storage_account.ops_sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = timestamp() 
  expiry = timeadd(timestamp(), "8760h")

  permissions {
    read    = false
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

resource "azurerm_virtual_machine_extension" "iaas_diagnostics_linux" {
#   depends_on           = [azurerm_virtual_machine_extension.network_watcher_linux, azurerm_virtual_machine_extension.log_analytics_linux]
  
  name                 = "vm_iaas_diags_linux"
  location             = var.location
  resource_group_name  = var.rg
  virtual_machine_name = azurerm_virtual_machine.netmonbox.name
  publisher            = "Microsoft.Azure.Diagnostics"
  type                 = "LinuxDiagnostic"
  type_handler_version = "3.0"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${local.storagename}",
      "storageAccountSasToken" : "${data.azurerm_storage_account_sas.ops_storage_account.sas}"
    }
    PROTECTED_SETTINGS

  tags = var.tags
}