# ============================================
# Resource Group
# ============================================

resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# ============================================
# Random suffix for unique names
# ============================================

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ============================================
# SQL Server & Database
# ============================================

resource "azurerm_mssql_server" "main" {
  name                         = "${var.project_name}-sqlserver-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = var.sql_max_size_gb
  sku_name       = var.sql_sku_name
  zone_redundant = false

  tags = var.tags
}

# Firewall rule pour autoriser les services Azure
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall rules pour IPs spécifiques
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  count            = length(var.allowed_ip_addresses)
  name             = "AllowedIP-${count.index}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = var.allowed_ip_addresses[count.index]
  end_ip_address   = var.allowed_ip_addresses[count.index]
}

# ============================================
# Application Insights (optionnel)
# ============================================

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_application_insights ? 1 : 0
  name                = "${var.project_name}-${var.environment}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_application_insights" "main" {
  count               = var.enable_application_insights ? 1 : 0
  name                = "${var.project_name}-${var.environment}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main[0].id
  application_type    = "web"

  tags = var.tags
}

# ============================================
# App Service Plan (Linux pour Docker)
# ============================================

resource "azurerm_service_plan" "backend" {
  name                = "${var.project_name}-backend-plan-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.backend_app_service_plan_sku

  tags = var.tags
}

# ============================================
# App Service (Backend API)
# ============================================

resource "azurerm_linux_web_app" "backend" {
  name                = "${var.project_name}-backend-api-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.backend.id

  site_config {
    always_on = var.backend_app_service_plan_sku != "F1" && var.backend_app_service_plan_sku != "D1"
    
    application_stack {
      docker_image_name   = var.backend_docker_image
      docker_registry_url = "https://ghcr.io"
    }

    cors {
      allowed_origins = [
        "https://${azurerm_static_web_app.frontend.default_host_name}",
        "http://localhost:5173",
        "http://localhost:3000"
      ]
      support_credentials = true
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = var.environment == "prod" ? "Production" : "Development"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL" = "https://ghcr.io"
    
    # Connection String SQL
    "ConnectionStrings__DefaultConnection" = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    
    # OpenAI Configuration
    "OpenAI__ApiKey" = var.openai_api_key
    "OpenAI__Model"  = var.openai_model
    
    # Auth0 Configuration
    "Auth0__Domain"   = var.auth0_domain
    "Auth0__Audience" = var.auth0_audience
    
    # Application Insights (si activé)
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : ""
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  tags = var.tags
}

# ============================================
# Static Web App (Frontend)
# ============================================

resource "azurerm_static_web_app" "frontend" {
  name                = "${var.project_name}-frontend-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location == "eastus" ? "eastus2" : var.location
  sku_tier            = var.frontend_sku_tier
  sku_size            = var.frontend_sku_tier

  tags = var.tags
}

# ============================================
# Key Vault (optionnel)
# ============================================

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  count                       = var.enable_key_vault ? 1 : 0
  name                        = "${var.project_name}-kv-${random_string.suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  tags = var.tags
}

# Stocker les secrets dans Key Vault
resource "azurerm_key_vault_secret" "sql_connection_string" {
  count        = var.enable_key_vault ? 1 : 0
  name         = "sql-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main[0].id
}

resource "azurerm_key_vault_secret" "openai_api_key" {
  count        = var.enable_key_vault ? 1 : 0
  name         = "openai-api-key"
  value        = var.openai_api_key
  key_vault_id = azurerm_key_vault.main[0].id
}
