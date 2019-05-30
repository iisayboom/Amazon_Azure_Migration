provider "azurerm" {
  version = "~>1.5"
}

terraform {
  backend "azurerm" {
    storage_account_name = "your_storage_account_name"
    container_name = "your_container_name"
    key = "terraform.tfstate"
  }
}
