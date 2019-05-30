resource "azurerm_subnet" "subnet" {
  name                 = "TomtomVnetSubnet"
  resource_group_name  = "RG-weu-vnet-tomtom-default"
  virtual_network_name = "VNET-tomtom-default"
  address_prefix       = "x.x.x.x/xx"
}
