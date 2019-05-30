resource "azurerm_resource_group" "APSQL" {
  name     = "RG-APSQL-TERRAFORM"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "postgres" {
  name                = "release-notes"
  location            = "${azurerm_resource_group.APSQL.location}"
  resource_group_name = "${azurerm_resource_group.APSQL.name}"

  sku {
    name     = "GP_Gen5_2"
    capacity = 2
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 102400 //100 GB
    backup_retention_days = 8
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "your_database_username"
  administrator_login_password = "your_database_password"
  version                      = "9.6"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_postgresql_virtual_network_rule" "vnetRule" {
  name                                 = "your_vnet_name"
  resource_group_name                  = "${azurerm_postgresql_server.postgres.resource_group_name}"
  server_name                          = "${azurerm_postgresql_server.postgres.name}"
  subnet_id                            = "${azurerm_subnet.subnet.id}"
  ignore_missing_vnet_service_endpoint = true
}
