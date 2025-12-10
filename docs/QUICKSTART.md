# 🚀 Guide de Démarrage Rapide - Déploiement APG avec Terraform

Ce guide vous accompagne pas à pas pour déployer l'application APG sur Azure.

## ⏱️ Temps estimé: 15-20 minutes

## 📋 Prérequis

1. **Terraform installé**
   ```bash
   brew install terraform
   terraform --version  # Doit être >= 1.6
   ```

2. **Azure CLI installé** (déjà fait ✅)
   ```bash
   az --version
   ```

3. **Compte Azure actif** (déjà fait ✅)
   - Azure for Students avec crédits disponibles

4. **Clé OpenAI API**
   - Obtenez-la sur https://platform.openai.com/api-keys

## 🎯 Étapes de déploiement

### Étape 1: Configuration initiale

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Infra/terraform

# Créer le fichier de configuration
cp terraform.tfvars.example terraform.tfvars
```

### Étape 2: Éditer terraform.tfvars

Ouvrez `terraform.tfvars` et remplissez:

```hcl
subscription_id = "4ab02dca-abe6-4a04-bdd1-1dd301da6645"

# SQL Database
sql_admin_password = "VotreMotDePasse!Complexe123"  # Min 8 caractères

# OpenAI
openai_api_key = "sk-VOTRE-CLE-OPENAI"

# Optionnel: Autoriser votre IP pour accéder à la BDD
allowed_ip_addresses = ["VOTRE.IP.PUBLIQUE"]
```

Pour obtenir votre IP publique:
```bash
../scripts/get-my-ip.sh
```

### Étape 3: Déployer avec le script automatisé

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Infra
./scripts/deploy.sh
```

Le script va:
1. ✅ Vérifier les prérequis
2. ✅ Se connecter à Azure
3. ✅ Initialiser Terraform
4. ✅ Créer un plan de déploiement
5. ✅ Déployer toutes les ressources (5-10 minutes)

### Étape 4: Récupérer les informations de déploiement

Après le déploiement, notez les informations importantes:

```bash
cd terraform

# URL du backend
terraform output backend_url

# URL du frontend
terraform output frontend_url

# API Key pour Static Web App (pour GitHub Actions)
terraform output -raw frontend_api_key
```

## 🔧 Configuration GitHub Actions

### Backend (APG-Backend)

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Backend

# Récupérer le nom de l'App Service
BACKEND_NAME=$(cd ../APG_Infra/terraform && terraform output -raw backend_app_name)

# Configurer les secrets GitHub
gh secret set AZURE_WEBAPP_NAME -b"$BACKEND_NAME" -R clauvisastek/APG-Backend

# Récupérer le profil de publication
az webapp deployment list-publishing-profiles \
  -n $BACKEND_NAME \
  -g $(cd ../APG_Infra/terraform && terraform output -raw resource_group_name) \
  --xml | gh secret set AZURE_WEBAPP_PUBLISH_PROFILE -R clauvisastek/APG-Backend
```

### Frontend (APG-Frontend)

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Front

# Récupérer l'API Token du Static Web App
FRONTEND_TOKEN=$(cd ../APG_Infra/terraform && terraform output -raw frontend_api_key)

# Configurer le secret GitHub
gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN -b"$FRONTEND_TOKEN" -R clauvisastek/APG-Frontend

# Mettre à jour l'URL du backend dans .env
BACKEND_URL=$(cd ../APG_Infra/terraform && terraform output -raw backend_url)
echo "VITE_API_URL=$BACKEND_URL" > .env.production
```

## 🔐 Configuration Auth0

1. Connectez-vous à [Auth0 Dashboard](https://manage.auth0.com/)

2. Ajoutez les URLs de callback:
   - Backend: `https://VOTRE-BACKEND.azurewebsites.net/callback`
   - Frontend: `https://VOTRE-FRONTEND.azurestaticapps.net`

3. Mettez à jour les "Allowed Web Origins" avec l'URL du frontend

## 📦 Déployer les applications

### Backend

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Backend

# Créer un tag pour déclencher le déploiement
git add .
git commit -m "chore: configure Azure deployment"
git push origin main
```

Le workflow GitHub Actions va automatiquement:
1. Builder l'image Docker
2. Pousser vers GitHub Container Registry
3. Déployer sur Azure App Service

### Frontend

```bash
cd /Users/clauviskitieu/Documents/Projets/DPO/Apps/APG_Front

# Mettre à jour avec la bonne URL backend
git add .env.production
git commit -m "chore: configure backend URL for production"
git push origin main
```

Le workflow GitHub Actions va automatiquement:
1. Builder l'application React
2. Déployer sur Azure Static Web App

## ✅ Vérification

1. **Backend API**: Visitez `https://VOTRE-BACKEND.azurewebsites.net/swagger`
2. **Frontend**: Visitez `https://VOTRE-FRONTEND.azurestaticapps.net`
3. **Base de données**: Connectez-vous avec Azure Data Studio ou SSMS

## 🔍 Commandes utiles

```bash
cd terraform

# Voir toutes les ressources créées
terraform show

# Voir les outputs
terraform output

# Voir un output spécifique
terraform output backend_url

# Mettre à jour l'infrastructure
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Détruire toutes les ressources
../scripts/destroy.sh
```

## 🐛 Dépannage

### Erreur: "Region not allowed"
- Vérifiez que vous utilisez `eastus` dans `terraform.tfvars`

### Erreur: "SQL password too weak"
- Le mot de passe doit contenir: majuscule, minuscule, chiffre, caractère spécial (min 8 caractères)

### Backend ne démarre pas
- Vérifiez les logs: `az webapp log tail -n BACKEND_NAME -g RESOURCE_GROUP`
- Vérifiez les variables d'environnement dans le portail Azure

### Frontend affiche des erreurs CORS
- Vérifiez que l'URL du backend est correcte dans `.env.production`
- Vérifiez la configuration CORS dans Azure App Service

## 💰 Coûts

Avec la configuration par défaut (dev):
- SQL Database Basic: ~5 €/mois
- App Service B1: ~13 €/mois
- Static Web App Free: 0 €/mois
- Application Insights: ~0-2 €/mois
- **Total: ~18-20 €/mois**

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez les logs Terraform
2. Consultez le portail Azure
3. Vérifiez les GitHub Actions
4. Consultez la documentation dans `/docs`
