data "azurerm_key_vault" "infra_secret_vault" {
  count               = var.deploy_postgres ? 0 : 1
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}
data "azurerm_key_vault_secret" "db_name" {
  count        = length(data.azurerm_key_vault.infra_secret_vault)==0 ? 0 : 1
  name         = var.review_db_dbname
  key_vault_id = data.azurerm_key_vault.infra_secret_vault[0].id
}

data "azurerm_key_vault_secret" "db_password" {
  count        = length(data.azurerm_key_vault.infra_secret_vault)==0 ? 0 : 1
  name         = var.review_db_password
  key_vault_id = data.azurerm_key_vault.infra_secret_vault[0].id
}

data "azurerm_key_vault_secret" "db_username" {
  count        = length(data.azurerm_key_vault.infra_secret_vault)==0 ? 0 : 1
  name         = var.review_db_username
  key_vault_id = data.azurerm_key_vault.infra_secret_vault[0].id
}

data "azurerm_key_vault_secret" "db_host" {
  count        = length(data.azurerm_key_vault.infra_secret_vault)==0 ? 0 : 1
  name         = var.review_db_hostname
  key_vault_id = data.azurerm_key_vault.infra_secret_vault[0].id
}

data "azurerm_key_vault_secret" "redis_url" {
  count        = length(data.azurerm_key_vault.infra_secret_vault)==0 ? 0 : 1
  name         = var.review_url_redis_name
  key_vault_id = data.azurerm_key_vault.infra_secret_vault[0].id
}
