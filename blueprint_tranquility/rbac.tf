
# # for each resource group created, create an AAD security group and apply privileges O/C/R

# # Creating the owner AAD security group and assign privileges
# resource "azuread_group" "aad_group_owner" {
# count = "${var.provision_rbac ? 1 : 0}" 

#   for_each  = module.resource_group_hub.names
#     name    = "${each.value}-owner"
# #   members = [ "${azuread_user.example.object_id}" /*, more users */ ]
# }

# resource "azurerm_role_assignment" "aad_role_assign_owner" {
# count = "${var.provision_rbac ? 1 : 0}" 

#   for_each  = module.resource_group_hub.ids
#     scope                = each.value
#     role_definition_name = "Owner"
#     principal_id         = azuread_group.aad_group_owner[each.key].id
# }

# # Creating the contributor AAD security group and assign privileges
# resource "azuread_group" "aad_group_contrib" {
# count = "${var.provision_rbac ? 1 : 0}" 

#   for_each  = module.resource_group_hub.names
#     name    = "${each.value}-contributor"
# #   members = [ "${azuread_user.example.object_id}" /*, more users */ ]
# }

# resource "azurerm_role_assignment" "aad_role_assign_contrib" {
# count = "${var.provision_rbac ? 1 : 0}" 

#   for_each  = module.resource_group_hub.ids
#     scope                = each.value
#     role_definition_name = "Contributor"
#     principal_id         = azuread_group.aad_group_contrib[each.key].id
# }

# # Creating the reader AAD security group and assign privileges
# resource "azuread_group" "aad_group_reader" {
# count = "${var.provision_rbac ? 1 : 0}" 

#   for_each  = module.resource_group_hub.names
#     name    = "${each.value}-reader"
# #   members = [ "${azuread_user.example.object_id}" /*, more users */ ]
# }

# resource "azurerm_role_assignment" "aad_role_assign_reader" {
#   for_each  = module.resource_group_hub.ids
#     scope                = each.value
#     role_definition_name = "Reader"
#     principal_id         = azuread_group.aad_group_reader[each.key].id
# }
# }