output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
output "aks_host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}
output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
  sensitive = true
}
output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "ssh_key" {
  value     = tls_private_key.key
  sensitive = true
}
output "config" {
    value = <<CONFIGURE
    Run the following commands to configure kubernetes clients:   
    $ terraform output kube_config_raw > ~/.kube/aks-config
    $ export KUBECONFIG=~/.kube/aks-config
    CONFIGURE
}