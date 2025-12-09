# ============================================
# Resource Group
# ============================================

output "resource_group_name" {
  description = "Nom du resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Région du resource group"
  value       = azurerm_resource_group.main.location
}

# ============================================
# SQL Server & Database
# ============================================

output "sql_server_name" {
  description = "Nom du SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "FQDN du SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Nom de la base de données"
  value       = azurerm_mssql_database.main.name
}

output "sql_connection_string" {
  description = "Connection string SQL (sensible)"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

# ============================================
# Backend (App Service)
# ============================================

output "backend_app_name" {
  description = "Nom de l'App Service backend"
  value       = azurerm_linux_web_app.backend.name
}

output "backend_url" {
  description = "URL du backend API"
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "backend_default_hostname" {
  description = "Hostname par défaut du backend"
  value       = azurerm_linux_web_app.backend.default_hostname
}

# ============================================
# Frontend (Static Web App)
# ============================================

output "frontend_app_name" {
  description = "Nom du Static Web App"
  value       = azurerm_static_web_app.frontend.name
}

output "frontend_url" {
  description = "URL du frontend"
  value       = "https://${azurerm_static_web_app.frontend.default_host_name}"
}

output "frontend_default_hostname" {
  description = "Hostname par défaut du frontend"
  value       = azurerm_static_web_app.frontend.default_host_name
}

output "frontend_api_key" {
  description = "API Key pour déployer le Static Web App (sensible)"
  value       = azurerm_static_web_app.frontend.api_key
  sensitive   = true
}

# ============================================
# Application Insights
# ============================================

output "application_insights_instrumentation_key" {
  description = "Clé d'instrumentation Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.main[0].connection_string : null
  sensitive   = true
}

# ============================================
# Key Vault
# ============================================

output "key_vault_name" {
  description = "Nom du Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].name : null
}

output "key_vault_uri" {
  description = "URI du Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].vault_uri : null
}

# ============================================
# Informations de déploiement
# ============================================

output "deployment_instructions" {
  description = "Instructions pour compléter le déploiement"
  value = <<-EOT
  
  ╔════════════════════════════════════════════════════════════════╗
  ║          🎉 Infrastructure APG déployée avec succès !          ║
  ╚════════════════════════════════════════════════════════════════╝
  
  📋 RESSOURCES CRÉÉES:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  🔹 Resource Group: ${azurerm_resource_group.main.name}
  🔹 SQL Server:     ${azurerm_mssql_server.main.name}
  🔹 Database:       ${azurerm_mssql_database.main.name}
  🔹 Backend API:    ${azurerm_linux_web_app.backend.name}
  🔹 Frontend:       ${azurerm_static_web_app.frontend.name}
  
  🌐 URLs:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  Backend API:  https://${azurerm_linux_web_app.backend.default_hostname}
  Frontend:     https://${azurerm_static_web_app.frontend.default_host_name}
  
  📝 PROCHAINES ÉTAPES:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  1. Configurer les GitHub Secrets pour le Backend:
     gh secret set AZURE_WEBAPP_NAME -b"${azurerm_linux_web_app.backend.name}"
     gh secret set AZURE_WEBAPP_PUBLISH_PROFILE -b"$(az webapp deployment list-publishing-profiles -n ${azurerm_linux_web_app.backend.name} -g ${azurerm_resource_group.main.name} --xml)"
  
  2. Configurer les GitHub Secrets pour le Frontend:
     gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN -b"<utiliser terraform output -raw frontend_api_key>"
  
  3. Configurer Auth0:
     - Ajouter l'URL du backend dans "Allowed Callback URLs"
     - Ajouter l'URL du frontend dans "Allowed Web Origins"
  
  4. Mettre à jour le frontend avec l'URL du backend:
     VITE_API_URL=https://${azurerm_linux_web_app.backend.default_hostname}
  
  5. Pousser le code sur GitHub pour déclencher le déploiement automatique
  
  Pour afficher les secrets sensibles:
  - terraform output -raw sql_connection_string
  - terraform output -raw frontend_api_key
  
  EOT
}
