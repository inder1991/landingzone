output "vnet_ids_hub" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.connectivity :
    vnet_name => vnet.id
  }
}

output "vnet_ids_identity" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.identity :
    vnet_name => vnet.id
  }
}

output "vnet_ids_mgmt" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.mgmt :
    vnet_name => vnet.id
  }
}

output "subnet_ids_hub" {
  value = {
    for subnet_name, subnet in azurerm_subnet.connectivity :
    subnet_name => subnet.id
  }
}


output "subnet_ids_identity" {
  value = {
    for subnet_name, subnet in azurerm_subnet.identity :
    subnet_name => subnet.id
  }
}

output "subnet_ids_mgmt" {
  value = {
    for subnet_name, subnet in azurerm_subnet.mgmt :
    subnet_name => subnet.id
  }
}

# output "keyvault_id" {
#   description = "The ID of the Azure Key Vault"
#   value       = azurerm_key_vault.router[each.key].id
# }

# output "keyvault_uri" {
#   description = "The URI of the Azure Key Vault"
#   value       = azurerm_key_vault.router[each.key].vault_uri
# }

# output "key_encryption_key_url" {
#   description = "The KeyEncryptionKeyURL for each virtual machine's disk encryption settings"
#   value       = [for vm_key in azurerm_key_vault_key.router : vm_key.id]
# }