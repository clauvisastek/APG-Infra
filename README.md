# APG Infrastructure - Terraform

Infrastructure as Code pour l'application APG déployée sur Microsoft Azure.

## 📁 Structure

```
APG_Infra/
├── terraform/
│   ├── main.tf                 # Configuration principale
│   ├── variables.tf            # Variables d'entrée
│   ├── outputs.tf              # Sorties (URLs, connection strings)
│   ├── providers.tf            # Configuration des providers
│   ├── backend.tf              # Configuration du backend Terraform
│   ├── modules/                # Modules réutilisables
│   │   ├── database/           # Azure SQL Database
│   │   ├── app-service/        # App Services (Backend API)
│   │   └── static-web-app/     # Static Web App (Frontend)
│   └── environments/           # Configurations par environnement
│       ├── dev.tfvars
│       ├── staging.tfvars
│       └── prod.tfvars
├── scripts/
│   ├── deploy.sh               # Script de déploiement
│   └── destroy.sh              # Script de destruction
└── README.md
```

## 🚀 Prérequis

- [Terraform](https://www.terraform.io/downloads) >= 1.6
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Compte Azure avec une subscription active

## 📦 Ressources créées

### 1. Resource Group
- Groupe de ressources pour tous les services

### 2. Azure SQL Database
- SQL Server avec authentification SQL
- Base de données APG (tier Basic pour MVP)
- Firewall configuré pour autoriser les services Azure
- IP publique autorisée pour administration

### 3. App Service (Backend API)
- App Service Plan Linux (B1)
- App Service pour l'API .NET 8
- Configuration Docker
- Variables d'environnement (Connection String, OpenAI, Auth0)
- Logs et monitoring activés

### 4. Static Web App (Frontend)
- Static Web App pour React/Vite
- CDN intégré
- SSL automatique
- Configuration CORS
- Intégration GitHub Actions

### 5. Key Vault (Optionnel)
- Stockage sécurisé des secrets
- OpenAI API Key
- Connection strings

## 🔧 Configuration

### 1. Authentification Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Initialisation Terraform

```bash
cd terraform
terraform init
```

### 3. Vérifier le plan

```bash
terraform plan -var-file="environments/dev.tfvars"
```

### 4. Déploiement

```bash
terraform apply -var-file="environments/dev.tfvars"
```

## 📝 Variables à configurer

Créez un fichier `terraform.tfvars` ou utilisez les fichiers d'environnement :

```hcl
# Identifiants Azure
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"

# Configuration générale
project_name    = "apg"
environment     = "dev"
location        = "eastus"

# Base de données
sql_admin_username = "apgadmin"
sql_admin_password = "VotreMDP!Complexe123"  # À stocker dans Key Vault

# Backend
openai_api_key = "sk-your-openai-key"

# Auth0
auth0_domain   = "astekcanada.ca.auth0.com"
auth0_audience = "https://api.apg-astek.com"

# GitHub (pour Static Web App)
github_repo_url = "https://github.com/clauvisastek/APG-Frontend"
```

## 🔐 Gestion des secrets

**NE JAMAIS** commiter les secrets dans Git !

1. Créez un fichier `terraform.tfvars` (ignoré par Git)
2. Ou utilisez Azure Key Vault
3. Ou utilisez des variables d'environnement :

```bash
export TF_VAR_sql_admin_password="YourPassword"
export TF_VAR_openai_api_key="sk-your-key"
```

## 📊 Outputs

Après déploiement, Terraform affiche :

- URL du Backend API
- URL du Frontend
- Connection String SQL Server
- Nom des ressources créées

## 🗑️ Destruction

Pour supprimer toutes les ressources :

```bash
terraform destroy -var-file="environments/dev.tfvars"
```

## 💰 Coûts estimés

| Ressource | Tier | Coût/mois |
|-----------|------|-----------|
| SQL Database | Basic | ~5 € |
| App Service | B1 | ~13 € |
| Static Web App | Free | 0 € |
| **Total** | | **~18-20 €** |

## 🔄 CI/CD

Les workflows GitHub Actions sont automatiquement configurés pour :
- Frontend : Déploiement automatique vers Static Web App
- Backend : Build Docker et déploiement vers App Service

## 📚 Documentation

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service](https://docs.microsoft.com/azure/app-service/)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
