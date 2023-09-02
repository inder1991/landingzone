locals {
  empty_list   = []
  empty_map    = tomap({})
  empty_string = ""
}
locals {
  location                         = var.location
  settings                         = var.configure_hub_networking_resources.settings
  resource_group_names_management  = var.resource_group_names_management
  resource_group_names_identity    = var.resource_group_names_identity
  resource_group_names_hub         = var.resource_group_names_hub
  resource_group_names_rsf         = var.resource_group_names_rsf
  ddos_protection_plan_resource_id = var.existing_ddos_protection_plan_resource_id
  custom_settings                  = var.custom_settings_by_resource_type

}
