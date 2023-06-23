resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 2048
}
resource "azurerm_resource_group" "rg" {
    name = var.az_resource_name
    location = var.az_region
    tags = var.tags
} 
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_resource_group.rg]
  create_duration = "90s"
} 
resource "azurerm_kubernetes_cluster" "aks" {
    name = var.aks_name
    location = var.az_region
    resource_group_name = var.az_resource_name
    dns_prefix = "${var.aks_name}-dns"
    linux_profile {
        admin_username = var.aks_admin_name
        ssh_key {
            key_data = trimspace(tls_private_key.key.public_key_openssh)
        }
    }

    default_node_pool {
        name = "default"
        node_count = var.aks_agent_count
        vm_size = "Standard_D2_v2"
    }

    service_principal {
        client_id = var.az_service_principal_client_id
        client_secret = var.az_service_principal_client_secret
    }

}
