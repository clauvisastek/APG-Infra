# ============================================
# Variables générales
# ============================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "project_name" {
  description = "Nom du projet (préfixe pour toutes les ressources)"
  type        = string
  default     = "apg"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit être dev, staging ou prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags communs pour toutes les ressources"
  type        = map(string)
  default = {
    Project     = "APG"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

# ============================================
# Variables SQL Database
# ============================================

variable "sql_admin_username" {
  description = "Nom d'utilisateur admin SQL Server"
  type        = string
  default     = "apgadmin"
}

variable "sql_admin_password" {
  description = "Mot de passe admin SQL Server (min 8 caractères, majuscule, minuscule, chiffre, caractère spécial)"
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "APGDb"
}

variable "sql_sku_name" {
  description = "SKU de la base de données (Basic, S0, S1, etc.)"
  type        = string
  default     = "Basic"
}

variable "sql_max_size_gb" {
  description = "Taille maximale de la base de données en GB"
  type        = number
  default     = 2
}

variable "allowed_ip_addresses" {
  description = "Liste des adresses IP autorisées à accéder au SQL Server"
  type        = list(string)
  default     = []
}

# ============================================
# Variables Backend (App Service)
# ============================================

variable "backend_app_service_plan_sku" {
  description = "SKU du App Service Plan (B1, B2, S1, etc.)"
  type        = string
  default     = "B1"
}

variable "backend_docker_image" {
  description = "Image Docker pour le backend (registry/image:tag)"
  type        = string
  default     = "mcr.microsoft.com/dotnet/samples:aspnetapp"
}

variable "openai_api_key" {
  description = "Clé API OpenAI pour Market Trends"
  type        = string
  sensitive   = true
}

variable "openai_model" {
  description = "Modèle OpenAI à utiliser"
  type        = string
  default     = "gpt-4o"
}

variable "auth0_domain" {
  description = "Domaine Auth0"
  type        = string
  default     = "astekcanada.ca.auth0.com"
}

variable "auth0_audience" {
  description = "Audience Auth0"
  type        = string
  default     = "https://api.apg-astek.com"
}

# ============================================
# Variables Frontend (Static Web App)
# ============================================

variable "frontend_github_repo_url" {
  description = "URL du repository GitHub du frontend"
  type        = string
  default     = "https://github.com/clauvisastek/APG-Frontend"
}

variable "frontend_github_branch" {
  description = "Branche GitHub à déployer"
  type        = string
  default     = "main"
}

variable "frontend_sku_tier" {
  description = "Tier du Static Web App (Free ou Standard)"
  type        = string
  default     = "Free"
}

# ============================================
# Variables optionnelles
# ============================================

variable "enable_key_vault" {
  description = "Activer Azure Key Vault pour les secrets"
  type        = bool
  default     = false
}

variable "enable_application_insights" {
  description = "Activer Application Insights pour le monitoring"
  type        = bool
  default     = true
}
