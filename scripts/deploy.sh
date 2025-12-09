#!/bin/bash

# ============================================
# Script de déploiement Terraform pour APG
# ============================================

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        APG Infrastructure - Terraform Deployment               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Vérifier les prérequis
echo -e "${YELLOW}⏳ Vérification des prérequis...${NC}"

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform n'est pas installé${NC}"
    echo "Installez Terraform: brew install terraform"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI n'est pas installé${NC}"
    echo "Installez Azure CLI: brew install azure-cli"
    exit 1
fi

echo -e "${GREEN}✅ Tous les prérequis sont installés${NC}"
echo ""

# Vérifier la connexion Azure
echo -e "${YELLOW}⏳ Vérification de la connexion Azure...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}🔐 Connexion à Azure requise...${NC}"
    az login
fi

SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
echo -e "${GREEN}✅ Connecté à Azure: ${SUBSCRIPTION_NAME}${NC}"
echo ""

# Demander l'environnement
echo -e "${BLUE}📋 Configuration du déploiement${NC}"
echo ""
echo "Sélectionnez l'environnement:"
echo "  1) dev (Development)"
echo "  2) staging"
echo "  3) prod (Production)"
read -p "Choix [1]: " ENV_CHOICE
ENV_CHOICE=${ENV_CHOICE:-1}

case $ENV_CHOICE in
    1) ENV="dev" ;;
    2) ENV="staging" ;;
    3) ENV="prod" ;;
    *) echo -e "${RED}Choix invalide${NC}"; exit 1 ;;
esac

echo -e "${GREEN}✓ Environnement: ${ENV}${NC}"

# Vérifier si le fichier tfvars existe
TFVARS_FILE="environments/${ENV}.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    echo -e "${RED}❌ Fichier ${TFVARS_FILE} introuvable${NC}"
    echo "Créez le fichier à partir de l'exemple:"
    echo "  cp environments/${ENV}.tfvars.example environments/${ENV}.tfvars"
    exit 1
fi

# Demander les secrets sensibles
echo ""
echo -e "${YELLOW}🔐 Configuration des secrets${NC}"
echo ""

read -sp "Mot de passe SQL Admin (min 8 caractères): " SQL_PASSWORD
echo ""

read -sp "OpenAI API Key: " OPENAI_KEY
echo ""

if [ -z "$SQL_PASSWORD" ] || [ -z "$OPENAI_KEY" ]; then
    echo -e "${RED}❌ Les secrets sont obligatoires${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Secrets configurés${NC}"
echo ""

# Initialiser Terraform
echo -e "${YELLOW}⏳ [1/4] Initialisation de Terraform...${NC}"
terraform init
echo -e "${GREEN}✅ Terraform initialisé${NC}"
echo ""

# Valider la configuration
echo -e "${YELLOW}⏳ [2/4] Validation de la configuration...${NC}"
terraform validate
echo -e "${GREEN}✅ Configuration valide${NC}"
echo ""

# Afficher le plan
echo -e "${YELLOW}⏳ [3/4] Génération du plan de déploiement...${NC}"
terraform plan \
    -var-file="$TFVARS_FILE" \
    -var="sql_admin_password=$SQL_PASSWORD" \
    -var="openai_api_key=$OPENAI_KEY" \
    -out=tfplan

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  ATTENTION: Vous êtes sur le point de déployer l'infrastructure${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

read -p "Continuer avec le déploiement? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Déploiement annulé${NC}"
    rm -f tfplan
    exit 0
fi

# Appliquer le plan
echo ""
echo -e "${YELLOW}⏳ [4/4] Déploiement de l'infrastructure (5-10 minutes)...${NC}"
terraform apply tfplan

# Nettoyer le plan
rm -f tfplan

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║            🎉 Déploiement terminé avec succès !                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Afficher les outputs importants
echo -e "${BLUE}📋 Informations importantes:${NC}"
echo ""
terraform output deployment_instructions

echo ""
echo -e "${YELLOW}💡 Pour afficher les valeurs sensibles:${NC}"
echo "  terraform output -raw sql_connection_string"
echo "  terraform output -raw frontend_api_key"
echo ""

echo -e "${GREEN}✅ Déploiement terminé !${NC}"
