terraform {
    backend "azurerm" {
    }
}

provider "azurerm" {
  version = "<= 1.35.0"
}

data "azurerm_subscription" "current" {
}