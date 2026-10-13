resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.project_name
  sku_tier            = "Free" # no charge for the control plane; you pay for nodes, NAT and load balancer

  # Needed later for passwordless pod and GitHub identity (workload identity)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.private.id
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    outbound_type     = "userAssignedNATGateway"
    load_balancer_sku = "standard"

    # AKS defaults the service range to 10.0.0.0/16, which would overlap our VNet.
    # Pick a range that does not collide with 10.0.0.0/16.
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  # The NAT gateway must be attached to the subnet before the cluster is created
  depends_on = [azurerm_subnet_nat_gateway_association.private]
}

# Let the nodes pull images from our registry
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# Lets the cluster's identity attach its load balancer and nodes to our subnet
resource "azurerm_role_assignment" "aks_subnet_join" {
  scope                            = azurerm_subnet.private.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_kubernetes_cluster.main.identity[0].principal_id
  skip_service_principal_aad_check = true
}
