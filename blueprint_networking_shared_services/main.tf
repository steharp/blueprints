terraform {
    required_version = ">= 0.12.6"
    backend "azurerm" {
    }
}

provider "azurerm" {
  version = "<= 1.35.0"
}

data "azurerm_subscription" "current" {
}
