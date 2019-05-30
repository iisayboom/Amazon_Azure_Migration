resource "azurerm_resource_group" "rg" {
  name     = "RG-ACR-TERRAFORM"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                     = "AcrTerraform"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["East US"]
}
