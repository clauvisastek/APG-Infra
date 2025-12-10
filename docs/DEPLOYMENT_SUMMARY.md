# 🎉 Déploiement APG sur Azure - Résumé Complet

## ✅ Infrastructure Déployée

Toutes les ressources Azure ont été créées avec succès via Terraform dans la région **Central US**.

### 🌐 URLs de Production

| Service | URL | Statut |
|---------|-----|--------|
| **Backend API** | https://apg-backend-api-dev.azurewebsites.net | ✅ Déployé |
| **Frontend** | https://white-ground-0f7e2d310.3.azurestaticapps.net | ✅ Déployé |
| **Swagger UI** | https://apg-backend-api-dev.azurewebsites.net/swagger | 📝 API Docs |

### 📦 Ressources Azure

| Ressource | Nom | Type |
|-----------|-----|------|
| Resource Group | `apg-dev-rg` | Conteneur |
| SQL Server | `apg-sqlserver-q08600.database.windows.net` | Azure SQL |
| Database | `APGDb` | SQL Database (Basic) |
| App Service Plan | `apg-backend-plan-dev` | Linux B1 |
| App Service | `apg-backend-api-dev` | .NET 8 + Docker |
| Static Web App | `apg-frontend-dev` | React + Vite |
| Application Insights | `apg-dev-insights` | Monitoring |

---

## 🔄 Déploiement Automatique (CI/CD)

### GitHub Actions configuré pour :

#### Backend (APG-Backend)
- ✅ Build Docker image automatique
- ✅ Push vers GitHub Container Registry
- ✅ Déploiement vers Azure App Service
- **Déclencheur** : Push sur `main`
- **Workflow** : `.github/workflows/azure-deploy.yml`

#### Frontend (APG-Frontend)
- ✅ Build React + Vite
- ✅ Déploiement vers Static Web App
- ✅ Preview deployments pour PRs
- **Déclencheur** : Push sur `main` ou Pull Requests
- **Workflow** : `.github/workflows/azure-static-web-apps.yml`

---

## 🔐 Secrets GitHub Configurés

### Backend Repository (APG-Backend)
- ✅ `AZURE_WEBAPP_NAME`
- ✅ `AZURE_WEBAPP_PUBLISH_PROFILE`

### Frontend Repository (APG-Frontend)
- ✅ `AZURE_STATIC_WEB_APPS_API_TOKEN`
- ⚠️ `AUTH0_CLIENT_ID` (à ajouter manuellement)

---

## 📝 Prochaines Étapes

### 1. Configurer Auth0 ⚠️ IMPORTANT

Connectez-vous à [Auth0 Dashboard](https://manage.auth0.com/) et mettez à jour :

**Application Settings** :
- **Allowed Callback URLs** :
  ```
  https://apg-backend-api-dev.azurewebsites.net/callback,
  https://white-ground-0f7e2d310.3.azurestaticapps.net,
  http://localhost:5173
  ```

- **Allowed Logout URLs** :
  ```
  https://white-ground-0f7e2d310.3.azurestaticapps.net,
  http://localhost:5173
  ```

- **Allowed Web Origins** :
  ```
  https://white-ground-0f7e2d310.3.azurestaticapps.net,
  http://localhost:5173
  ```

- **Allowed Origins (CORS)** :
  ```
  https://apg-backend-api-dev.azurewebsites.net,
  https://white-ground-0f7e2d310.3.azurestaticapps.net
  ```

### 2. Ajouter AUTH0_CLIENT_ID au Frontend

```bash
# Récupérez votre Client ID depuis Auth0
gh secret set AUTH0_CLIENT_ID -b"VOTRE_CLIENT_ID" -R clauvisastek/APG-Frontend
```

### 3. Initialiser la Base de Données

Deux options :

**Option A : Via Azure Data Studio**
1. Connectez-vous à `apg-sqlserver-q08600.database.windows.net`
2. User: `apgadmin`
3. Password: (voir terraform output)
4. Exécutez les migrations depuis `/migrations`

**Option B : Via le Backend**
```bash
# Les migrations EF Core s'exécuteront automatiquement au démarrage
# Vérifiez les logs dans Azure Portal
```

### 4. Tester l'Application

#### Backend API
```bash
# Health check
curl https://apg-backend-api-dev.azurewebsites.net/health

# Swagger UI
open https://apg-backend-api-dev.azurewebsites.net/swagger
```

#### Frontend
```bash
# Ouvrir l'application
open https://white-ground-0f7e2d310.3.azurestaticapps.net
```

---

## 🛠️ Gestion et Maintenance

### Voir les Logs

#### Backend
```bash
# Via Azure CLI
az webapp log tail -n apg-backend-api-dev -g apg-dev-rg

# Via portail Azure
https://portal.azure.com → App Services → apg-backend-api-dev → Log stream
```

#### Frontend
```bash
# Voir les déploiements
gh run list --repo clauvisastek/APG-Frontend

# Voir les logs d'un run spécifique
gh run view <RUN_ID> --repo clauvisastek/APG-Frontend --log
```

### Mettre à Jour l'Infrastructure

```bash
cd APG_Infra/terraform

# Modifier terraform.tfvars si nécessaire
nano terraform.tfvars

# Appliquer les changements
terraform plan
terraform apply
```

### Redéployer Manuellement

#### Backend
```bash
cd APG_Backend
git commit --allow-empty -m "trigger: redeploy backend"
git push origin main
```

#### Frontend
```bash
cd APG_Front
git commit --allow-empty -m "trigger: redeploy frontend"
git push origin main
```

---

## 💰 Coûts Estimés

| Service | Tier | Coût/mois |
|---------|------|-----------|
| SQL Database | Basic (2 GB) | ~5 € |
| App Service | B1 (1 core, 1.75 GB RAM) | ~13 € |
| Static Web App | Free | 0 € |
| Application Insights | Pay-as-you-go | ~2 € |
| **Total** | | **~20 €/mois** |

---

## 🔍 Commandes Utiles

### Terraform
```bash
cd APG_Infra/terraform

# Voir les outputs
terraform output

# Voir les ressources créées
terraform state list

# Voir une ressource spécifique
terraform state show azurerm_linux_web_app.backend
```

### Azure CLI
```bash
# Lister les ressources
az resource list -g apg-dev-rg -o table

# Voir les App Settings
az webapp config appsettings list -n apg-backend-api-dev -g apg-dev-rg

# Redémarrer l'API
az webapp restart -n apg-backend-api-dev -g apg-dev-rg
```

### GitHub CLI
```bash
# Voir les workflows
gh workflow list --repo clauvisastek/APG-Backend

# Voir les runs récents
gh run list --repo clauvisastek/APG-Backend --limit 5

# Déclencher un workflow manuellement
gh workflow run "Deploy Backend to Azure App Service" --repo clauvisastek/APG-Backend
```

---

## 📚 Documentation

- [Architecture](./docs/ARCHITECTURE.md)
- [API Endpoints](./docs/API_ENDPOINTS_CFO.md)
- [Market Trends](./docs/MARKET_TRENDS_API.md)
- [Margin Calculator](./docs/MARGIN_CALCULATOR_IMPLEMENTATION.md)

---

## ✅ Checklist de Validation

- [x] Infrastructure déployée sur Azure
- [x] GitHub Actions configurés
- [x] Secrets GitHub en place
- [x] Backend déployé automatiquement
- [x] Frontend déployé automatiquement
- [ ] Auth0 configuré avec les URLs de production
- [ ] AUTH0_CLIENT_ID ajouté aux secrets
- [ ] Base de données initialisée
- [ ] Tests fonctionnels effectués
- [ ] Documentation utilisateur partagée avec le board

---

## 🆘 Support

**En cas de problème** :

1. Vérifiez les logs des workflows GitHub Actions
2. Consultez les logs Azure (App Service Log Stream)
3. Vérifiez Application Insights pour les erreurs
4. Consultez la documentation dans `/docs`

**Contacts** :
- DevOps : Vérifier les GitHub Actions
- Azure : Vérifier le portail Azure (portal.azure.com)
- Auth0 : Vérifier manage.auth0.com

---

## 🎯 Résumé des URLs Importantes

| Type | URL |
|------|-----|
| 🌐 Frontend | https://white-ground-0f7e2d310.3.azurestaticapps.net |
| 🔌 Backend API | https://apg-backend-api-dev.azurewebsites.net |
| 📊 Swagger | https://apg-backend-api-dev.azurewebsites.net/swagger |
| 🔐 Auth0 Dashboard | https://manage.auth0.com/ |
| ☁️ Azure Portal | https://portal.azure.com/ |
| 💻 GitHub Backend | https://github.com/clauvisastek/APG-Backend |
| 💻 GitHub Frontend | https://github.com/clauvisastek/APG-Frontend |
| 🏗️ GitHub Infra | https://github.com/clauvisastek/APG-Infra |

---

**🎉 Félicitations ! Votre MVP APG est maintenant déployé et prêt pour les tests du board !**
