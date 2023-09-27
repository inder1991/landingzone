output "vnet_ids_hub" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.connectivity :
    vnet_name => vnet.id
  }
}

output "vnet_ids_identity" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.identity :
    vnet_name => vnet.id
  }
}

output "vnet_ids_mgmt" {
  value = {
    for vnet_name, vnet in azurerm_virtual_network.mgmt :
    vnet_name => vnet.id
  }
}

output "subnet_ids_hub" {
  value = {
    for subnet_name, subnet in azurerm_subnet.connectivity :
    subnet_name => subnet.id
  }
}


output "subnet_ids_identity" {
  value = {
    for subnet_name, subnet in azurerm_subnet.identity :
    subnet_name => subnet.id
  }
}

output "subnet_ids_mgmt" {
  value = {
    for subnet_name, subnet in azurerm_subnet.mgmt :
    subnet_name => subnet.id
  }
}

output "lb_dns" {
  value = azurerm_lb.example.dns_name_label
}