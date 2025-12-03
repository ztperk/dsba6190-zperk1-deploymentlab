// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID

# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}


// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }

  tags = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = local.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  // this lets the subnet talk to Storage over the VNet
  service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
}

resource "azurerm_mssql_server" "sql_server" {
  name                = "sql-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"

  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = local.tags
}

resource "azurerm_mssql_database" "sql_db" {
  name      = "sqldb-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic" # lab friendly

  max_size_gb = 2

  tags = local.tags
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.subnet.id
}