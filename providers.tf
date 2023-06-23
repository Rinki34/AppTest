terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
      features {}
    }
  }

  required_version = ">= 0.14"
}
