provider "cloudfoundry" {
  api_url  = var.api_url
  user     = local.infrastructure_secrets.PAAS-USERNAME
  password = local.infrastructure_secrets.PAAS-PASSWORD
}

provider "statuscake" {
  api_token = local.infrastructure_secrets.SC-PASSWORD
}

locals {
  azure_credentials = jsondecode(var.AZURE_CREDENTIALS)
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
  subscription_id = var.AZURE_CREDENTIALS == "{}" ? "" : local.azure_credentials.subscriptionId
  client_id       = var.AZURE_CREDENTIALS == "{}" ? "" : local.azure_credentials.clientId
  client_secret   = var.AZURE_CREDENTIALS == "{}" ? "" : local.azure_credentials.clientSecret
  tenant_id       = var.AZURE_CREDENTIALS == "{}" ? "" : local.azure_credentials.tenantId
}

terraform {
  required_version = "1.2.8"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.73.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.51.3"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.1.0"
    }
  }
}
