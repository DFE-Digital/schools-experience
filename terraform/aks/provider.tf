terraform {
  required_version = "=1.4.6"

  backend "azurerm" {
    container_name = "gse-tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.52"
    }
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}