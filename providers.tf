provider "azurerm" {
    version = ">=1.32"
    subscription_id = var.az_subscription_id
    tenant_id = var.az_tenant_id
    client_id = var.az_service_principal_client_id
    client_secret = var.az_service_principal_client_secret
    features {}
}
