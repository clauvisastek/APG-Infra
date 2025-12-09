#!/bin/bash

# ============================================
# Script de destruction Terraform pour APG
# ============================================

set -e

# Couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     ⚠️  APG Infrastructure - Destruction des ressources  ⚠️     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Demander l'environnement
echo "Quel environnement voulez-vous détruire?"
echo "  1) dev (Development)"
echo "  2) staging"
echo "  3) prod (Production)"
read -p "Choix: " ENV_CHOICE

case $ENV_CHOICE in
    1) ENV="dev" ;;
    2) ENV="staging" ;;
    3) ENV="prod" ;;
    *) echo -e "${RED}Choix invalide${NC}"; exit 1 ;;
esac

echo ""
echo -e "${RED}⚠️  ATTENTION: Vous êtes sur le point de DÉTRUIRE toutes les ressources de l'environnement ${ENV}${NC}"
echo -e "${RED}⚠️  Cette action est IRRÉVERSIBLE !${NC}"
echo -e "${RED}⚠️  Toutes les données seront PERDUES !${NC}"
echo ""

read -p "Tapez 'DESTROY' pour confirmer: " CONFIRM
if [ "$CONFIRM" != "DESTROY" ]; then
    echo -e "${YELLOW}Destruction annulée${NC}"
    exit 0
fi

TFVARS_FILE="environments/${ENV}.tfvars"

echo ""
echo -e "${YELLOW}⏳ Destruction en cours...${NC}"
terraform destroy -var-file="$TFVARS_FILE"

echo ""
echo -e "${YELLOW}✅ Toutes les ressources ont été détruites${NC}"
