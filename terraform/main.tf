terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-devops-platform"
  location = "Central US"

  tags = {
    project     = "cloud-native-devops-platform"
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-devops-platform"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = ["10.0.0.0/16"]

  tags = {
    project     = "cloud-native-devops-platform"
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-devops-platform"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    project     = "cloud-native-devops-platform"
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_virtual_network.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-devops-platform"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-devops-platform"

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_b4ps_v2"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  tags = {
    project     = "cloud-native-devops-platform"
    environment = "dev"
    managed_by  = "terraform"
  }
}