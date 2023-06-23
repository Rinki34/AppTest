resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 2048
}
resource "azurerm_resource_group" "rg" {
    name = var.az_resource_name
    count = "${var.az_resource_group == "true" ? 1 : 0}"
    
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
    depends_on = [time_sleep.wait_30_seconds]
    linux_profile {
        admin_username = var.aks_admin_name

        ssh_key {
            key_data = trimspace(tls_private_key.key.public_key_openssh)
        }
    }

    default_node_pool {
        name = "default"
        node_count = var.aks_agent_count
        vm_size = var.aks_vm_size
        os_disk_size_gb = 50
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

resource "kubernetes_namespace" "istio" {
    metadata {
        name = "istio-system"
    } 
    provider = kubernetes.aks
    depends_on = [ azurerm_kubernetes_cluster.aks ]
}

resource "kubernetes_namespace" "sockshop" {
    metadata {
        name = "sock-shop"
        labels = {
          istio-injection = "enabled"
        }
    } 
    provider = kubernetes.aks
    depends_on = [ azurerm_kubernetes_cluster.aks ]
}

resource "null_resource" "save-kube-config" {
    triggers = {
        config = azurerm_kubernetes_cluster.aks.kube_config_raw
    }
    provisioner "local-exec" {
        command = "mkdir -p ~/.kube && echo '${azurerm_kubernetes_cluster.aks.kube_config_raw}' > $HOME/.kube/config && export KUBECONFIG=$HOME/.kube/config"
    }
    provisioner "local-exec" {
        command = "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.4.3 TARGET_ARCH=x86_64 sh -"
    }
    provisioner "local-exec" {
        command = "helm template istio-1.4.3/install/kubernetes/helm/istio-init --namespace istio-system | kubectl apply -f- --kubeconfig=$HOME/.kube/config && sleep 30s"
    }
    provisioner "local-exec" {
        command = "helm template istio-1.4.3/install/kubernetes/helm/istio --values istio-1.4.3/install/kubernetes/helm/istio/values-istio-demo.yaml --namespace istio-system | kubectl apply -f- --kubeconfig=$HOME/.kube/config"
    }
    provisioner "local-exec" {
        command = "kubectl get pods -n istio-system --kubeconfig=$HOME/.kube/config && kubectl apply -f app/complete-demo-v1.yaml -n sock-shop --kubeconfig=$HOME/.kube/config"
    }        

    depends_on = [azurerm_kubernetes_cluster.aks, kubernetes_namespace.sockshop, kubernetes_namespace.istio]
}
