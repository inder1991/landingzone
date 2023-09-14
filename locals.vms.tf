locals {
  vm_names = local.vm_configurations.vm_configs
  vm_names_by_scope = {
    for vm_name in local.vm_names :
    vm_name.config.name => vm_name
  }
  vm_name_locations = keys(local.vm_names_by_scope)
}

# The following locals are used to check enable and disable flags 
locals {
  deploy_vm_name = {
    for vm, vm_name in local.vm_names_by_scope :
    vm =>
    vm_name.enabled
  }
}


locals {
  azurerm_network_interface = {
    for vm, vm_configs in local.vm_names_by_scope :
    vm => {

      # Resource definition attributes
        name                    = vm_configs.config.name
        location                = local.location
        resource_group_name     = vm_configs.config.resource_group_name
        subnet_id   = azurerm_subnet.connectivity["rsf-subnet"].id

    }
    if local.deploy_vm_name[vm]
  }
}


# The following locals are used to build the map of VMs
# to deploy.

locals {
  azurerm_linux_virtual_machine = {
    for vm, vm_configs in local.vm_names_by_scope :
    vm => {

      # Resource definition attributes
        name                    = vm_configs.config.name
        location                = local.location
        resource_group_name     = vm_configs.config.resource_group_name
        network_interface_ids   = [azurerm_subnet.connectivity["rsf-subnet"].id]
        vm_size                 = vm_configs.config.vm_size
        admin_username          = "adminuser"
        image_id                = vm_configs.config.image_id
        disable_password_authentication = true
        #tags                    = merge(local.vm.tags, { "description" : each.value.description })

        os_disk = {
            caching              = "ReadWrite"
            storage_account_type = "Standard_LRS"
        }

        source_image_reference = {
            publisher = "Canonical"
            offer     = "UbuntuServer"
            sku       = "18.04-LTS"
            version   = vm_configs.config.source_image_reference[0].version
        }

        admin_ssh_key = {
            username   = "adminuser"
            public_key = file("~/.ssh/id_rsa.pub")
        }

    }
    if local.deploy_vm_name[vm]
  }
}


# The following locals are used to modify the tags of vm resource
locals {
  vm = {
    tags = merge(var.tags, { "resource" : "vm" })
  }
}


