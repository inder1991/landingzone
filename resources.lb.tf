resource "azurerm_network_security_group" "router" {
  name                = "router-nsg"
  location            = local.location
  resource_group_name = var.rg_hub

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create the Azure Load Balancer
resource "azurerm_lb" "router" {
  name                = "router-lb"
  location            = local.location
  resource_group_name = var.rg_hub
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.router[0].id
  }
}

# Create the health probe (SSH on port 22)
resource "azurerm_lb_probe" "router" {
  name                = "router-probe"
  resource_group_name = var.rg_hub
  loadbalancer_id     = azurerm_lb.router.id
  protocol            = "Tcp"
  port                = 22
}

# Create the backend address pool
resource "azurerm_lb_backend_address_pool" "router" {
  name                = "router-backend-pool"
  resource_group_name = var.rg_hub
  loadbalancer_id     = azurerm_lb.router.id
}

# Attach VMs to the backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "router" {
  count                           = 2
  network_interface_id            = azurerm_network_interface.router[count.index].id
  ip_configuration_name           = "ipconfig"
  backend_address_pool_id         = azurerm_lb_backend_address_pool.router.id
}