data "azurerm_key_vault" "infra_secret_vault" {
  name                = var.infra_key_vault_name
  resource_group_name = var.key_vault_resource_group
}

data "azurerm_key_vault_secret" "sc_password" {
  name         = var.statuscake_password_name
  key_vault_id = data.azurerm_key_vault.infra_secret_vault.id
}
