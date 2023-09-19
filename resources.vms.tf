resource "azurerm_key_vault" "router" {

  provider = azurerm.hub

  # Mandatory resource attributes
  name                       = "router-keyvault"
  location                   = local.location
  resource_group_name        = var.rg_hub
  tenant_id                  = "48607b0a-d613-4283-9d21-391d1570cebb"
  enabled_for_disk_encryption = true

  sku_name = "standard"
  purge_protection_enabled = false
}

resource "azurerm_availability_set" "router" {

  provider = azurerm.hub

  # Mandatory resource attributes
  name                = "router-availability-set"
  location            = local.location
  resource_group_name = var.rg_hub
}

# resource "azurerm_key_vault_key" "router" {

#   provider = azurerm.hub

#   # Mandatory resource attributes
#   name         = "disk-encryption-key"
#   key_vault_id = azurerm_key_vault.router.id

#   key_type = "RSA"

#   key_opts = ["encrypt", "decrypt"]
#   depends_on = [
#     azurerm_key_vault.router
#   ]
# }



resource "azurerm_network_interface" "vm-nic" {
for_each = local.azurerm_network_interface

  provider = azurerm.hub

  # Mandatory resource attributes
  name                    = each.value.name
  location                = local.location
  resource_group_name    = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "connectivity" {
  for_each = local.azurerm_linux_virtual_machine

  # Mandatory resource attributes
  name                    = each.value.name
  location                = local.location
  resource_group_name     = each.value.resource_group_name
  network_interface_ids   = [azurerm_network_interface.vm-nic[each.key].id]
  size                    = each.value.vm_size
  admin_username          = "adminuser"
  availability_set_id     = azurerm_availability_set.router.id
  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"  
    storage_account_type = "Standard_LRS"
    #encryption_at_host   = true
  }

  source_image_reference {

    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_key_vault.router,
    azurerm_availability_set.router
  ]
}

resource "azurerm_virtual_machine_extension" "enable_encryption_at_rtr1" {
  virtual_machine_id = azurerm_linux_virtual_machine.connectivity["test-vm"].id
  name               = "enableEncryptionAtHost"
  publisher          = "Microsoft.Azure.Security"
  type               = "AzureDiskEncryption"
  type_handler_version = "2.4"

  protected_settings = jsonencode({
    "EncryptionOperation"     = "EnableEncryption",
    "KeyVaultURL"            = azurerm_key_vault.router.vault_uri,
    "KeyEncryptionKeyURL"    = null,  # Set to null for platform-managed keys
    "KeyEncryptionAlgorithm" = null,  # Set to null for platform-managed keys
    "VolumeType"             = "All"
  })

  settings = jsonencode({
    "DiskEncryptionKeyVaultUrl" = azurerm_key_vault.router.vault_uri,
    "KeyEncryptionKeyURL"       = null,  # Set to null for platform-managed keys
    "KeyEncryptionAlgorithm"    = null,  # Set to null for platform-managed keys
    "VolumeType"                = "All"
  })
}

resource "azurerm_virtual_machine_extension" "enable_encryption_at_rtr2" {
  virtual_machine_id = azurerm_linux_virtual_machine.connectivity["test-vm-2"].id
  name               = "enableEncryptionAtHost"
  publisher          = "Microsoft.Azure.Security"
  type               = "AzureDiskEncryption"
  type_handler_version = "2.4"

  protected_settings = jsonencode({
    "EncryptionOperation"     = "EnableEncryption",
    "KeyVaultURL"            = azurerm_key_vault.router.vault_uri,
    "KeyEncryptionKeyURL"    = null,  # Set to null for platform-managed keys
    "KeyEncryptionAlgorithm" = null,  # Set to null for platform-managed keys
    "VolumeType"             = "All"
  })

  settings = jsonencode({
    "DiskEncryptionKeyVaultUrl" = azurerm_key_vault.router.vault_uri,
    "KeyEncryptionKeyURL"       = null,  # Set to null for platform-managed keys
    "KeyEncryptionAlgorithm"    = null,  # Set to null for platform-managed keys
    "VolumeType"                = "All"
  })
}

#### Working

resource "azurerm_network_interface" "example" {
  count               = length(var.network_interfaces)
  name                = var.network_interfaces[count.index].name
  location            = local.location
  resource_group_name = var.rg_hub

  ip_configuration {
    name                          = "config"
    subnet_id                     = var.network_interfaces[count.index].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

