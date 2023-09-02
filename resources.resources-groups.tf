resource "azurerm_resource_group" "management-rg" {
  provider = azurerm.management
  for_each = local.resource_group_names_by_scope.management
  name     = each.key
  location = lookup(each.value, "location", null)
  tags     = merge(local.base_options.rg.tags, { "description" : lookup(each.value, "description", null) })
}

resource "azurerm_resource_group" "hub-rg" {
  provider = azurerm.hub
  for_each = local.resource_group_names_by_scope.hub
  name     = each.key
  location = lookup(each.value, "location", null)
  tags     = merge(local.base_options.rg.tags, { "description" : lookup(each.value, "description", null) })
}

resource "azurerm_resource_group" "identity-rg" {
  for_each = local.resource_group_names_by_scope.identity
  provider = azurerm.identity
  name     = each.key
  location = lookup(each.value, "location", null)
  tags     = merge(local.base_options.rg.tags, { "description" : lookup(each.value, "description", null) })
}

resource "azurerm_resource_group" "rsf-rg" {
  for_each = local.resource_group_names_by_scope.rsf
  provider = azurerm.rsf
  name     = each.key
  location = lookup(each.value, "location", null)
  tags     = merge(local.base_options.rg.tags, { "description" : lookup(each.value, "description", null) })

}
