variable "tags" {
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default = {
    ProjectName  = "ABCD testing"
    ProjectOwner = "inder"
    deployedBy   = "terraform"
  }

}

variable "existing_ddos_protection_plan_resource_id" {
  type        = string
  description = "If specified, module will skip creation of DDoS Protection Plan and use existing."
  default     = ""
}

variable "hub_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_sub_id)) || var.hub_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }

}
variable "management_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.management_sub_id)) || var.management_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }

}
variable "rsf_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.rsf_sub_id)) || var.rsf_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }

}
variable "identity_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.identity_sub_id)) || var.identity_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }

}
variable "location" {
  type        = string
  description = "Sets the default location used for resource deployments where needed."
  default     = "uksouth"

}

variable "resource_group_names_by_scope" {
  type        = any
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default     = {}
}

variable "resource_group_names_management" {
  type        = map(any)
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default = {
    "test1" = {
      "name"        = "test1"
      "location"    = "uksouth"
      "description" = "testing"
    }

  }

}
variable "resource_group_names_identity" {
  type        = map(any)
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default = {
    "identity-location" = {
      "name"        = "identity-location"
      "location"    = "australiacentral"
      "description" = "testing"
    }
  }
}
variable "resource_group_names_hub" {
  type        = map(any)
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default = {
    "test1" = {
      "name"        = "test1"
      "location"    = "uksouth"
      "description" = "testing"
    }
  }
}
variable "resource_group_names_rsf" {
  type        = map(any)
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default = {

  }
}

variable "custom_settings_by_resource_type" {
  type        = any
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default = {
  }
}

variable "configure_hub_networking_resources" {
  type = object({
    settings = optional(object({
      hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            name                         = string
            resource_group_name          = string
            description                  = string
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
              })
            ), [])
            virtual_network_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                name                     = optional(string, "")
                public_ip_name           = optional(string, "")
                address_prefix           = optional(string, "")
                gateway_sku_expressroute = optional(string, "")
                gateway_sku_vpn          = optional(string, "")
                advanced_vpn_settings = optional(object({
                  enable_bgp                       = optional(bool, null)
                  active_active                    = optional(bool, null)
                  private_ip_address_allocation    = optional(string, "")
                  default_local_network_gateway_id = optional(string, "")
                  vpn_client_configuration = optional(list(
                    object({
                      address_space = list(string)
                      aad_tenant    = optional(string, null)
                      aad_audience  = optional(string, null)
                      aad_issuer    = optional(string, null)
                      root_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      revoked_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      radius_server_address = optional(string, null)
                      radius_server_secret  = optional(string, null)
                      vpn_client_protocols  = optional(list(string), null)
                      vpn_auth_types        = optional(list(string), null)
                    })
                  ), [])
                  bgp_settings = optional(list(
                    object({
                      asn         = optional(number, null)
                      peer_weight = optional(number, null)
                      peering_addresses = optional(list(
                        object({
                          ip_configuration_name = optional(string, null)
                          apipa_addresses       = optional(list(string), null)
                        })
                      ), [])
                    })
                  ), [])
                  custom_route = optional(list(
                    object({
                      address_prefixes = optional(list(string), [])
                    })
                  ), [])
                }), {})
              }), {})
            }), {})
          })
        })
      ))
      })
    )
  })

  default = {
    settings = {
      # Create two hub networks 
      # and link to DDoS protection plan if created
      hub_networks = [
        { enabled = true
          config = {
            address_space                   = ["10.100.0.0/22", ]
            location                        = "uksouth"
            dns_servers                     = [""]
            name                            = "hub-1"
            description                     = "hub-1"
            enable_hub_network_mesh_peering = true
            resource_group_name             = "hub"
            link_to_ddos_protection_plan    = false
            subnets = [
              {
                name             = "rsf-subnet"
                address_prefixes = ["10.100.1.0/24"]

              }
            ]
            virtual_network_gateway = {
              enabled = false
              config = {
                name            = "vpngw"
                gateway_sku_vpn = "VpnGw3AZ"
                public_ip_name  = "pub-ip"
                address_prefix  = "10.100.4.0/24"
                advanced_vpn_settings = {
                  private_ip_address_allocation = "Dynamic"
                  enable_bgp                    = true
                  active_active                 = true
                }
                vpn_client_configuration = [
                  {
                    address_space = ["10.100.4.4/24"]

                  }
                ]
                bgp_settings = [
                  {}
                ]
                custom_route = [
                  {}
                ]

              }
            }
          }
        }
        ,
        {
          enabled = false
          config = {
            address_space                   = ["10.101.0.0/22", ]
            location                        = "uksouth"
            name                            = "hub-2"
            description                     = "hub-2"
            dns_servers                     = [""]
            enable_hub_network_mesh_peering = true
            resource_group_name             = "hub"
            link_to_ddos_protection_plan    = false
            subnets                         = []
          }
        }
      ]
    }
  }
}


variable "configure_identity_networking_resources" {
  type = object({
    settings = optional(object({
      identity_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            name                         = string
            resource_group_name          = string
            description                  = string
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
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
      # Create two identity networks 
      # and link to DDoS protection plan if created
      identity_networks = [
        { enabled = true
          config = {
            address_space                   = ["10.100.11.0/22", ]
            location                        = "uksouth"
            dns_servers                     = [""]
            name                            = "identity-1"
            description                     = "identity-1"
            enable_identity_network_mesh_peering = true
            resource_group_name             = "identity-rg"
            link_to_ddos_protection_plan    = false
            subnets = [
              {
                name             = "identity-subnet"
                address_prefixes = ["10.100.11.0/24"]

              }
            ]
          }
        }
      ]
      
    }
  }
}


variable "configure_mgmt_networking_resources" {
  type = object({
    settings = optional(object({
      mgmt_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            name                         = string
            resource_group_name          = string
            description                  = string
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
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
      # Create two mgmt networks 
      # and link to DDoS protection plan if created
      mgmt_networks = [
        { enabled = true
          config = {
            address_space                   = ["10.100.11.0/22", ]
            location                        = "uksouth"
            dns_servers                     = [""]
            name                            = "mgmt-1"
            description                     = "mgmt-1"
            enable_mgmt_network_mesh_peering = true
            resource_group_name             = "mgmt-rg"
            link_to_ddos_protection_plan    = false
            subnets = [
              {
                name             = "mgmt-subnet"
                address_prefixes = ["10.100.11.0/24"]

              }
            ]
          }
        }
      ]
      
    }
  }
}


variable "vm_names" {
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
        { enabled = true
          config = {
            name            = "test-vm"
            image_id        = "1.0.0"
            resource_group_name  = "hub"
            vnet_name       = "hub-1"
            subnet_name     = "rsf-subnet"
            vm_size         = "Standard_DS2_v2"
            source_image_reference = [
              {
                publisher = "Canonical"
                offer     = "UbuntuServer"
                sku       = "18.04-LTS"
                version   = "1.0.0"
              }
            ]
          }
          
        },
        { enabled = true
          config = {
            name            = "test-vm-2"
            image_id        = "1.0.0"
            resource_group_name  = "hub"
            vnet_name       = "hub-1"
            subnet_name     = "rsf-subnet"
            vm_size         = "Standard_DS2_v2"
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
