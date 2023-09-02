
locals {
  default_resource_groups_hub = {
    "hub" = {
      "name"        = "hub"
      "location"    = local.location
      "description" = "hub-for-transit-gateway"
    }
  }
  default_resource_groups_rsf = {
    "rsf" = {
      "name"        = "rsf"
      "location"    = local.location
      "description" = "spoke-workload"
    }
  }
  default_resource_groups_management = {
    "management" = {
      "name"        = "management"
      "location"    = local.location
      "description" = "spoke-management"
    }
  }
  default_resource_groups_identity = {
    "identity" = {
      "name"        = "identity"
      "location"    = local.location
      "description" = "spoke-identity"
    }
  }
  resource_group_names_by_scope = {
    "management" = merge(local.resource_group_names_management, local.default_resource_groups_management)
    "hub"        = merge(local.resource_group_names_hub, local.default_resource_groups_hub)
    "identity"   = merge(local.resource_group_names_identity, local.default_resource_groups_identity)
    "rsf"        = merge(local.resource_group_names_rsf, local.default_resource_groups_rsf)
  }
  # Mandatory core Enterprise resource groups
  base_options = {
    "rg" = {

      tags = merge(var.tags, { "resource" : "resource-group" })
    }

  }
}
