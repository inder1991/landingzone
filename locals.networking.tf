locals {
  hub_networks = local.settings.hub_networks
  hub_networks_by_scope = {
    for hub_network in local.hub_networks :
    hub_network.config.name => hub_network
  }
  hub_network_locations = keys(local.hub_networks_by_scope)
  private_ip_address_allocation_values = [
    "Dynamic",
    "Static",
  ]
}

# The following locals are used to check enable and disable flags 
locals {
  deploy_hub_network = {
    for hub_name, hub_network in local.hub_networks_by_scope :
    hub_name =>
    hub_network.enabled
  }
  deploy_virtual_network_gateway = {
    for hub_name, hub_network in local.hub_networks_by_scope :
    hub_name =>
    hub_network.config.virtual_network_gateway.enabled
  }
}

locals {
  azurerm_public_ip = flatten([
    for azurerm_public_ip in values(local.azurerm_virtual_network_gateway_vpn).*.azurerm_public_ip :
    azurerm_public_ip
    if length(azurerm_public_ip) > 0
  ])
  azurerm_subnet = flatten([
    for subnets in local.subnets_by_virtual_network :
    subnets
  ])
}

# The following locals are used to build the map of Vnets
# to deploy.

locals {
  azurerm_virtual_network = {
    for hub_name, hub_config in local.hub_networks_by_scope :
    hub_name => {

      # Resource definition attributes
      name                = hub_name
      resource_group_name = hub_config.config.resource_group_name
      address_space       = hub_config.config.address_space
      location            = local.location
      description         = hub_config.config.description
      dns_servers         = hub_config.config.dns_servers
      tags                = local.vnet.tags
      ddos_protection_plan = hub_config.config.link_to_ddos_protection_plan ? [
        {
          id     = local.ddos_protection_plan_resource_id
          enable = true
        }
      ] : local.empty_list

    }
    if local.deploy_hub_network[hub_name]
  }
}


# The following locals are used to modify the tags of Vnets,Subnets resource
locals {
  vnet = {
    tags = merge(var.tags, { "resource" : "vnet" })
  }
  subnet = {
    tags = merge(var.tags, { "resourse" : "subnet" })
  }
}


# The following locals are used to build the map of Subnets
# to deploy.
locals {
  azurerm_subnet_connectivity = {
    for resource in local.azurerm_subnet :
    resource.name => resource
  }
}

locals {
  subnets_by_virtual_network = {
    for hub_name, hub_config in local.hub_networks_by_scope :
    hub_name => concat(
      # Get customer specified subnets and add additional required attributes
      [
        for subnet in hub_config.config.subnets : merge(
          subnet,
          {
            # Resource logic attributes
            //    resource_id = "${local.virtual_network_resource_id[location]}/subnets/${subnet.name}"
            location = local.location
            # Resource definition attributes
            resource_group_name         = hub_config.config.resource_group_name
            virtual_network_name        = hub_name
            service_endpoints           = try(local.custom_settings.azurerm_subnet["connectivity"][subnet.name].service_endpoints, null)
            service_endpoint_policy_ids = try(local.custom_settings.azurerm_subnet["connectivity"][subnet.name].service_endpoint_policy_ids, null)
          }
        )
      ],
      local.deploy_virtual_network_gateway[hub_name] ? [
        {

          location                  = local.location
          network_security_group_id = null
          route_table_id            = null
          # Resource definition attributes address_prefixes
          name                 = "GatewaySubnet"
          address_prefixes     = [hub_config.config.virtual_network_gateway.config.address_prefix, ]
          resource_group_name  = hub_config.config.resource_group_name
          virtual_network_name = hub_config.config.name

        }
      ] : local.empty_list,
    )
  }
}

# The following locals are used to build the map of VGW
# to deploy.

locals {
  azurerm_virtual_network_gateway = local.azurerm_virtual_network_gateway_vpn

  azurerm_virtual_network_gateway_vpn = {
    for hub_name, hub_network in local.hub_networks_by_scope :
    hub_network.config.name => {
      # Resource definition attributes
      //  name                = local.vpn_gateway_name
      name                = hub_network.config.name
      resource_group_name = hub_network.config.resource_group_name
      location            = local.location
      type                = "Vpn"
      sku                 = hub_network.config.virtual_network_gateway.config.gateway_sku_vpn
      ip_configuration = concat(
        [
          {
            name = "vgw-pip"
            private_ip_address_allocation = (
              contains(
                local.private_ip_address_allocation_values,
                hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation
              )
              ? hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation
              : null
            )
            subnet_id            = azurerm_subnet.connectivity["GatewaySubnet"].id
            public_ip_address_id = "/subscriptions/${var.hub_sub_id}/${hub_network.config.resource_group_name}/rsf/providers/Microsoft.Network/publicIPAddresses/${hub_network.config.virtual_network_gateway.config.public_ip_name}-1"
          }
        ],
        (
          coalesce(hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.active_active, false)
          ? [
            {
              name = "vgw-pip-2"
              private_ip_address_allocation = (
                contains(
                  local.private_ip_address_allocation_values,
                  hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation
                )
                ? hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation
                : null
              )
              subnet_id            = azurerm_subnet.connectivity["GatewaySubnet"].id
              public_ip_address_id = "/subscriptions/${var.hub_sub_id}/${hub_network.config.resource_group_name}/rsf/providers/Microsoft.Network/publicIPAddresses/${hub_network.config.virtual_network_gateway.config.public_ip_name}-2"
            }
          ]
          : local.empty_list
        )
      )

      vpn_type      = "RouteBased"
      enable_bgp    = lower(hub_network.config.virtual_network_gateway.config.gateway_sku_vpn) == "basic" ? null : coalesce(hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.enable_bgp, false)
      active_active = coalesce(hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.active_active, false)
      private_ip_address_enabled = (
        contains(
          local.private_ip_address_allocation_values,
          hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation
        )
        ? true
        : null
      )
      default_local_network_gateway_id = (
        hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.default_local_network_gateway_id != local.empty_string
        ? hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.default_local_network_gateway_id
        : null
      )
      generation               = "Generation2"
      vpn_client_configuration = hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.vpn_client_configuration
      bgp_settings             = hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.bgp_settings
      custom_route             = hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.custom_route
      tags                     = var.tags
      # Child resource definition attributes
      azurerm_public_ip = (
        concat(
          [
            {
              # Resource definition attributes
              name                = "${hub_network.config.virtual_network_gateway.config.public_ip_name}-1"
              resource_group_name = hub_network.config.resource_group_name
              location            = local.location
              tags                = var.tags
              sku                 = "Standard"
              allocation_method   = "Dynamic"


            }
          ],
          (
            coalesce(hub_network.config.virtual_network_gateway.config.advanced_vpn_settings.active_active, false)
            ? [
              {
                # Resource definition attributes
                name                = "${hub_network.config.virtual_network_gateway.config.public_ip_name}-2"
                resource_group_name = hub_network.config.resource_group_name
                location            = local.location
                tags                = var.tags
                sku                 = "Standard"
                allocation_method   = "Dynamic"

            }]
            : local.empty_list
          )
        )
      )
    }
    if hub_network.config.virtual_network_gateway.enabled
  }


}
