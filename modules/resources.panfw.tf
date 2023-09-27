resource "azurerm_network_security_group" "pan_fw_nsg" {
  provider = azurerm.hub

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name_pan

  security_rule {
    name                       = "pan-fw-nsg-allow-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "pan_fw_nic_1" {

    provider = azurerm.hub
  count               = length(var.network_interfaces_1)
  name                = var.network_interfaces_1[count.index].name
  location            = local.location
  resource_group_name = var.resource_group_name_pan

  ip_configuration {
    name                          = "config"
    subnet_id                     = var.network_interfaces_1[count.index].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_network_security_group.pan_fw_nsg
  ]
}


resource "azurerm_linux_virtual_machine" "pan_fw_vm_1" {
  provider = azurerm.hub
  
  count                 = length(var.pan_fw_config1.settings.vm_configs)
  name                  = var.pan_fw_config1.settings.vm_configs[count.index].config.name
  location              = var.location
  resource_group_name   = var.pan_fw_config1.settings.vm_configs[count.index].config.resource_group_name
  network_interface_ids = [azurerm_network_interface.pan_fw_nic_1[count.index].id]

  size = var.pan_fw_config1.settings.vm_configs[count.index].config.vm_size
  disable_password_authentication = false
  admin_username = var.pan_fw_config1.settings.vm_configs[count.index].config.admin_username
  admin_password = file("~/.ssh/passwd")

  os_disk {
    name              = "${var.pan_fw_config1.settings.vm_configs[count.index].config.name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.pan_fw_config1.settings.vm_configs[count.index].config.source_image_reference[0].publisher
    offer     = var.pan_fw_config1.settings.vm_configs[count.index].config.source_image_reference[0].offer
    sku       = var.pan_fw_config1.settings.vm_configs[count.index].config.source_image_reference[0].sku
    version   = var.pan_fw_config1.settings.vm_configs[count.index].config.source_image_reference[0].version
  }
  depends_on = [
    azurerm_network_interface.pan_fw_nic_1,
  ]
}


resource "azurerm_network_interface" "pan_fw_nic_2" {

    provider = azurerm.hub
  count               = length(var.network_interfaces_2)
  name                = var.network_interfaces_2[count.index].name
  location            = local.location
  resource_group_name = var.resource_group_name_pan

  ip_configuration {
    name                          = "config"
    subnet_id                     = var.network_interfaces_2[count.index].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_network_security_group.pan_fw_nsg
  ]
}


resource "azurerm_linux_virtual_machine" "pan_fw_vm_2" {
  provider = azurerm.hub
  
  count                 = length(var.pan_fw_config2.settings.vm_configs)
  name                  = var.pan_fw_config2.settings.vm_configs[count.index].config.name
  location              = var.location
  resource_group_name   = var.pan_fw_config2.settings.vm_configs[count.index].config.resource_group_name
  network_interface_ids = [azurerm_network_interface.pan_fw_nic_2[count.index].id]

  size = var.pan_fw_config2.settings.vm_configs[count.index].config.vm_size
  disable_password_authentication = false
  admin_username = var.pan_fw_config2.settings.vm_configs[count.index].config.admin_username
  admin_password = file("~/.ssh/passwd")

  os_disk {
    name              = "${var.pan_fw_config2.settings.vm_configs[count.index].config.name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.pan_fw_config2.settings.vm_configs[count.index].config.source_image_reference[0].publisher
    offer     = var.pan_fw_config2.settings.vm_configs[count.index].config.source_image_reference[0].offer
    sku       = var.pan_fw_config2.settings.vm_configs[count.index].config.source_image_reference[0].sku
    version   = var.pan_fw_config2.settings.vm_configs[count.index].config.source_image_reference[0].version
  }
  depends_on = [
    azurerm_network_interface.pan_fw_nic_2,
  ]
}