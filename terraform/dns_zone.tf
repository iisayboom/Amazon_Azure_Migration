resource "azurerm_resource_group" "test" {
  name     = "RG-DNS-TERRAFORM"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "your_domain_name"
  resource_group_name = "${azurerm_resource_group.test.name}"
  zone_type           = "Public"
}
