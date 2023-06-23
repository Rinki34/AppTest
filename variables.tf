variable "az_resource_name" {
    type = string
    description = "Azure resourcegroup for deployment"
}
variable "az_region" {
    type = string
    description = "Azure region for deployment"
    default = "North Europe"
}
variable "aks_name" {
    type = string
    description = "Managed Kubernetes Cluster name"
}

variable "aks_agent_count" {
    description = "AKS agent VM count"
    default = 2
}
variable "aks_vm_size" {
    type = string
    description = "Azure VM size"
    default = "Standard_DS2_v2"
}

variable "aks_admin_name" {
    type = string
    description = "Admin username"
    default = "azureuser"
}
variable "az_subscription_id" {
    type = string
}
variable "az_tenant_id" {
    type = string
}
variable "az_service_principal_client_id" {
    type = string
    description = "Service Principal Client ID"
}
variable "az_service_principal_client_secret" {
    type = string
    description = "Service Principal Client Secret"
}
variable "tags" {
    type = map
    default = {
        Environment = "Development"
        Dept = "Engineering"
  }
}


