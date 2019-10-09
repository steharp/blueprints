# TODO: 
# + Extension: Log Analytics 
# - Extension: Diagnostics 
# + Extension: Network Watcher 
# + Extension: Dependency Agent
# - Store the private key in in AKV

resource "tls_private_key" "ssh_netmon" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  netmon_admin_username = "netmon_user"
}

resource "azurerm_network_interface" "netmon_nic" {
  name                = "${var.computer_name}-nic"
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags

  ip_configuration {
    name      = "netmon-ipconfig"
    subnet_id = var.subnet_id

    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "netmonbox" {
  name                  = var.computer_name
  location              = var.location
  resource_group_name   = var.rg
  vm_size               = var.vm_size
  network_interface_ids = [azurerm_network_interface.netmon_nic.id]
  tags                  = var.tags
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.computer_name}-osdisk"
    managed_disk_type = "Premium_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = "32"
  }

  os_profile {
    computer_name  = var.computer_name
    admin_username = local.netmon_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${local.netmon_admin_username}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh_netmon.public_key_openssh
    }
  }

  identity {
    type = "SystemAssigned"
  }

#   provisioner "local-exec" {
#     command = "az vm restart --name ${azurerm_virtual_machine.netmonbox.name} --resource-group ${azurerm_virtual_machine.netmonbox.resource_group}"
#   }
# }

# locals {
#   arg_save_ssh_key = "cat > ~/.ssh/${azurerm_public_ip.paw_pip.fqdn}.private <<EOL\n${tls_private_key.ssh_paw.private_key_pem}\nEOL"
# }

# resource "null_resource" "save_ssh_key" {
#   provisioner "local-exec" {
#     command = local.arg_save_ssh_key
#   }

#   triggers = {
#     content = tls_private_key.ssh_netmon.private_key_pem
#     arg     = local.arg_save_ssh_key
#   }
}