resource "azurerm_virtual_network" "connectivity" {
  for_each = local.azurerm_virtual_network

  provider = azurerm.hub

  # Mandatory resource attributes
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  location            = local.location
  tags                = merge(local.vnet.tags, { "description" : each.value.description })

  dynamic "ddos_protection_plan" {
    for_each = each.value.ddos_protection_plan
    content {
      id     = ddos_protection_plan.value["id"]
      enable = ddos_protection_plan.value["enable"]
    }
  }
  depends_on = [
    azurerm_resource_group.hub-rg
  ]
}

resource "azurerm_subnet" "connectivity" {
  for_each = local.azurerm_subnet_connectivity

  provider = azurerm.hub

  # Mandatory resource attributes
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  # dependencies
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_virtual_network.connectivity,
  ]
}

resource "azurerm_public_ip" "connectivity" {
  for_each = {
    for public_ip in local.azurerm_public_ip : public_ip.name => public_ip
  }

  provider = azurerm.hub

  # Mandatory resource attributes
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method

  # Optional attributes
  sku  = each.value.sku
  tags = var.tags

  # dependencies
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_virtual_network.connectivity,
  ]
}

resource "azurerm_virtual_network_gateway" "connectivity" {
  for_each = local.azurerm_virtual_network_gateway_vpn

  provider = azurerm.hub

  # Mandatory resource attributes
  name                             = each.value.name
  resource_group_name              = each.value.resource_group_name
  location                         = local.location
  type                             = each.value.type
  sku                              = each.value.sku
  vpn_type                         = each.value.vpn_type
  enable_bgp                       = each.value.enable_bgp
  active_active                    = each.value.active_active
  private_ip_address_enabled       = each.value.private_ip_address_enabled
  default_local_network_gateway_id = each.value.default_local_network_gateway_id
  generation                       = each.value.generation
  tags                             = var.tags

  # Dynamic configuration blocks
  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      # Mandatory attributes
      subnet_id            = ip_configuration.value["subnet_id"]
      public_ip_address_id = ip_configuration.value["public_ip_address_id"]

      # Optional attributes
      name                          = try(ip_configuration.value["name"], null)
      private_ip_address_allocation = try(ip_configuration.value["private_ip_address_allocation"], null)
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = each.value.vpn_client_configuration
    content {
      # Mandatory attributes
      address_space = vpn_client_configuration.value["address_space"]
      # Optional attributes
      aad_tenant            = try(vpn_client_configuration.value["aad_tenant"], null)
      aad_audience          = try(vpn_client_configuration.value["aad_audience"], null)
      aad_issuer            = try(vpn_client_configuration.value["aad_issuer"], null)
      radius_server_address = try(vpn_client_configuration.value["radius_server_address"], null)
      radius_server_secret  = try(vpn_client_configuration.value["radius_server_secret"], null)
      vpn_client_protocols  = try(vpn_client_configuration.value["vpn_client_protocols"], null)
      vpn_auth_types        = try(vpn_client_configuration.value["vpn_auth_types"], null)

      dynamic "root_certificate" {
        for_each = try(vpn_client_configuration.value["root_certificate"], local.empty_list)
        content {
          name             = root_certificate.value["name"]
          public_cert_data = root_certificate.value["public_cert_data"]
        }
      }

      dynamic "revoked_certificate" {
        for_each = try(vpn_client_configuration.value["revoked_certificate"], local.empty_list)
        content {
          name       = revoked_certificate.value["name"]
          thumbprint = revoked_certificate.value["thumbprint"]
        }
      }
    }
  }
  dynamic "bgp_settings" {
    for_each = each.value.bgp_settings
    content {
      asn         = try(bgp_settings.value["asn"], null)
      peer_weight = try(bgp_settings.value["peer_weight"], null)

      dynamic "peering_addresses" {
        for_each = try(bgp_settings.value["peering_addresses"], local.empty_list)
        content {
          ip_configuration_name = try(peering_addresses.value["ip_configuration_name"], null)
          apipa_addresses       = try(peering_addresses.value["apipa_addresses"], null)
        }
      }
    }
  }
  dynamic "custom_route" {
    for_each = each.value.custom_route
    content {
      address_prefixes = try(custom_route.value["address_prefixes"], null)
    }
  }
  # dependencies
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_public_ip.connectivity,
    azurerm_virtual_network.connectivity,
  ]
}

## To create the identity vnet and subnet
resource "azurerm_virtual_network" "identity" {
  for_each = local.azurerm_virtual_network_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  location            = local.location
  tags                = merge(local.vnet.tags, { "description" : each.value.description })

  dynamic "ddos_protection_plan" {
    for_each = each.value.ddos_protection_plan
    content {
      id     = ddos_protection_plan.value["id"]
      enable = ddos_protection_plan.value["enable"]
    }
  }
  depends_on = [
    azurerm_resource_group.identity-rg
  ]
}

resource "azurerm_subnet" "identity" {
  for_each = local.azurerm_subnet_identity_connectivity

  provider = azurerm.identity

  # Mandatory resource attributes
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  # dependencies
  depends_on = [
    azurerm_resource_group.identity-rg,
    azurerm_virtual_network.identity,
  ]
}

## To create the mgmt vnet and subnet
resource "azurerm_virtual_network" "mgmt" {
  for_each = local.azurerm_virtual_network_mgmt

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  location            = local.location
  tags                = merge(local.vnet.tags, { "description" : each.value.description })

  dynamic "ddos_protection_plan" {
    for_each = each.value.ddos_protection_plan
    content {
      id     = ddos_protection_plan.value["id"]
      enable = ddos_protection_plan.value["enable"]
    }
  }
  depends_on = [
    azurerm_resource_group.management-rg
  ]
}

resource "azurerm_subnet" "mgmt" {
  for_each = local.azurerm_subnet_mgmt_connectivity

  provider = azurerm.management

  # Mandatory resource attributes
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  # dependencies
  depends_on = [
    azurerm_resource_group.management-rg,
    azurerm_virtual_network.mgmt,
  ]
}


## Vnet peering for management groups
resource "azurerm_virtual_network_peering" "peer_hub_to_identity" {
  for_each = local.azurerm_virtual_network

  provider = azurerm.hub

  name                         = "peer-hub-to-identity"
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.name
  #remote_virtual_network_id    = azurerm_subnet.identity["identity-subnet"].id
  remote_virtual_network_id    = azurerm_virtual_network.identity["identity-1"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  # dependencies
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_virtual_network.connectivity,
    azurerm_virtual_network.identity,
  ]
}

resource "azurerm_virtual_network_peering" "peer_hub_to_mgmt" {
  for_each = local.azurerm_virtual_network

  provider = azurerm.hub
  
  name                         = "peer-hub-to-mgmt"
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.mgmt["mgmt-1"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  # dependencies
  depends_on = [
    azurerm_resource_group.hub-rg,
    azurerm_virtual_network.connectivity,
    azurerm_virtual_network.mgmt,
  ]
}

resource "azurerm_virtual_network_peering" "peer_identity_to_hub" {
  for_each = local.azurerm_virtual_network_identity

  provider = azurerm.identity

  name                         = "peer-identity-to-hub"
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.connectivity["hub-1"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  # dependencies
    depends_on = [
      azurerm_resource_group.identity-rg,
      azurerm_virtual_network.connectivity,
      azurerm_virtual_network.identity,
    ]
  }

resource "azurerm_virtual_network_peering" "peer_mgmt_to_hub" {
  for_each = local.azurerm_virtual_network_mgmt

  provider = azurerm.management

  name                         = "peer-mgmt-to-hub"
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.connectivity["hub-1"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  # dependencies
    depends_on = [
      azurerm_resource_group.management-rg,
      azurerm_virtual_network.connectivity,
      azurerm_virtual_network.mgmt,
    ]
}

# resource "azurerm_virtual_network_peering" "peer_identity_to_hub2" {
#   for_each = local.azurerm_virtual_network_identity

#   provider = azurerm.identity

#   name                         = "peer-identity-to-hub2"
#   resource_group_name          = each.value.resource_group_name
#   virtual_network_name         = each.value.name
#   remote_virtual_network_id    = azurerm_virtual_network.connectivity["hub-2"].id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true

# # dependencies
#   depends_on = [
#     azurerm_resource_group.identity-rg,
#     azurerm_virtual_network.connectivity,
#     azurerm_virtual_network.identity,
#   ]
# }

# resource "azurerm_virtual_network_peering" "peer_mgmt_to_hub2" {
#   for_each = local.azurerm_virtual_network_mgmt

#   provider = azurerm.management

#   name                         = "peer-mgmt-to-hub2"
#   resource_group_name          = each.value.resource_group_name
#   virtual_network_name         = each.value.name
#   remote_virtual_network_id    = azurerm_virtual_network.connectivity["hub-2"].id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true

# # dependencies
#   depends_on = [
#     azurerm_resource_group.management-rg,
#     azurerm_virtual_network.connectivity,
#     azurerm_virtual_network.mgmt,
#   ]
# }
