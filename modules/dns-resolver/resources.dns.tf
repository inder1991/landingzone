resource "azurerm_storage_account" "example" {
  name                     = var.storageAccountName
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an availability set
resource "azurerm_availability_set" "example" {
  name                = var.asetName
  resource_group_name = var.rg_name
  location            = var.location
  platform_fault_domain_count   = 2
  platform_update_domain_count  = 2
  #sku = "Aligned"
}

# Create a network security group
resource "azurerm_network_security_group" "example" {
  name                = var.nsgName
  resource_group_name = var.rg_name
  location            = var.location

  security_rule {
    name                       = "allow_ssh_in"
    description                = "The only thing allowed is SSH"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }
}


# Create a public IP address
resource "azurerm_public_ip" "example" {
  resource_group_name = var.rg_name
  name                = var.pipName
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "example" {
  name                = var.nicName
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.example.id
  }

  depends_on = [azurerm_public_ip.example, azurerm_network_security_group.example]
}

# Create a virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = var.vmName
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.vmSize

  availability_set_id = azurerm_availability_set.example.id

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.ubuntuOSVersion
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.vmName
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.example.primary_blob_endpoint
  }
}

# Create a virtual machine extension to execute the shell script
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "${azurerm_virtual_machine.example.name}/setupdnsfirewall"
  virtual_machine_id   = azurerm_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${var.scriptUrl}"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "sh forwarderSetup.sh ${var.forwardIP} ${var.vnetAddressPrefix}"
    }
PROTECTED_SETTINGS

  depends_on = [azurerm_virtual_machine.example]
}