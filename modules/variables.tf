variable "tags" {
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default = {
    ProjectName  = "ABCD testing"
    ProjectOwner = "inder"
    deployedBy   = "terraform"
  }

}

variable "hub_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_sub_id)) || var.hub_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }

}
variable "location" {
  type        = string
  description = "Sets the default location used for resource deployments where needed."
  default     = "uksouth"

}

variable "rg_hub" {
  type        = string
  description = "Sets the default location used for resource group deployments where needed."
  default     = "hub"

}

variable "network_interfaces_1" {
  description = "List of network interface objects"
  type        = list(object({
    name            = string
    subnet_id       = string
  }))
  default = [
    {
    name            = "nic-1"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet"
    # Add other attributes
  },
  {
    name            = "nic-2"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet1"
  },

  {
    name            = "nic-3"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet3"
  }
  ]
}

variable "pan_fw_config1" {
  type = object({
    settings = optional(object({
      vm_configs = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            name            = string
            image_id        = string
            resource_group_name  = string
            vnet_name       = string
            subnet_name     = string
            vm_size         = string
            admin_username  = string
            source_image_reference = optional(list(
              object({
                publisher = string
                offer     = string
                sku       = string
                version   = string
              })
            ), [])
          })
        })
      ))
      })
    )
  })

  default = {
    settings = {
      vm_configs = [
        { enabled = false
          config = {
            name            = "test-vm"
            image_id        = "1.0.0"
            resource_group_name  = "hub"
            vnet_name       = "hub-1"
            subnet_name     = "rsf-subnet"
            vm_size         = "Standard_DS2_v2"
            admin_username  = "fwadmin"
            source_image_reference = [
              {
                publisher = "Canonical"
                offer     = "UbuntuServer"
                sku       = "18.04-LTS"
                version   = "1.0.0"
              }
            ]
          }
        }
      ]
    }
  }
}



variable "resource_group_name_pan" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "example-rg"
}

variable "network_security_group_name" {
  description = "Name of the Azure NSG."
  type        = string
  default     = "example-nsg"
}


variable "pan_fw_config2" {
  type = object({
    settings = optional(object({
      vm_configs = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            name            = string
            image_id        = string
            resource_group_name  = string
            vnet_name       = string
            subnet_name     = string
            vm_size         = string
            admin_username  = string
            source_image_reference = optional(list(
              object({
                publisher = string
                offer     = string
                sku       = string
                version   = string
              })
            ), [])
          })
        })
      ))
      })
    )
  })

  default = {
    settings = {
      vm_configs = [
        { enabled = false
          config = {
            name            = "test-vm-2"
            image_id        = "1.0.0"
            resource_group_name  = "hub"
            vnet_name       = "hub-1"
            subnet_name     = "rsf-subnet"
            vm_size         = "Standard_DS2_v2"
            admin_username  = "fwadmin"
            source_image_reference = [
              {
                publisher = "Redhat"
                offer     = "RHEL 8"
                sku       = "20.04-LTS"
                version   = "2.0.0"
              }
            ]
          } 
        }
      ]
    }
  }
}

variable "network_interfaces_2" {
  description = "List of network interface objects"
  type        = list(object({
    name            = string
    subnet_id       = string
  }))
  default = [
    {
    name            = "nic-1"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/test"
    # Add other attributes
  },
  {
    name            = "nic-2"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/test1"
  },

  {
    name            = "nic-3"
    subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/test3"
  }
  ]
}