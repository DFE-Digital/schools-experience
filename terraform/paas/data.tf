data "azurerm_key_vault" "vault" {
  name                = var.azure_key_vault
  resource_group_name = var.azure_resource_group
}

data "azurerm_key_vault_secret" "application" {
  key_vault_id = data.azurerm_key_vault.vault.id
  name         = "SE-SECRETS"
}

data "azurerm_key_vault_secret" "infrastructure" {
  key_vault_id = data.azurerm_key_vault.vault.id
  name         = "SE-INFRA-SECRETS"
}

locals {
  application_secrets    = yamldecode(data.azurerm_key_vault_secret.application.value)
  infrastructure_secrets = yamldecode(data.azurerm_key_vault_secret.infrastructure.value)
}
