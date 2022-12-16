resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "ak8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Staging"
  }
}