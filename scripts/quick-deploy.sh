#!/bin/bash
set -e

cd "$(dirname "$0")/../terraform"

echo "🚀 Démarrage du déploiement Terraform..."
echo "📂 Répertoire: $(pwd)"
echo ""

# Vérifier les fichiers
if [ ! -f "main.tf" ]; then
    echo "❌ Fichier main.tf introuvable!"
    exit 1
fi

echo "✅ Fichiers Terraform trouvés"
echo ""

# Apply
terraform apply -auto-approve

echo ""
echo "🎉 Déploiement terminé!"
