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

  provider = azurerm.hub

  # Mandatory resource attributes
  name                    = each.value.name
  location                = local.location
  resource_group_name     = each.value.resource_group_name
  network_interface_ids   = [azurerm_network_interface.vm-nic[each.key].id]
  size                    = each.value.vm_size
  admin_username          = "adminuser"
  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"  
    storage_account_type = "Standard_LRS"
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
    azurerm_resource_group.hub-rg
  ]
}