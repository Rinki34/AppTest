resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 2048
}
resource "azurerm_resource_group" "rg" {
    name = var.az_resource_name
    
    location = var.az_region
    tags = var.tags
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
provider "kubernetes" {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
    alias                  = "aks"
    version                = "1.11.1"
    load_config_file       = "false"
}
