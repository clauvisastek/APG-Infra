#!/bin/bash

# Script pour obtenir votre IP publique et l'ajouter au firewall SQL

echo "🌐 Récupération de votre IP publique..."
PUBLIC_IP=$(curl -s ifconfig.me)

if [ -z "$PUBLIC_IP" ]; then
    echo "❌ Impossible de récupérer l'IP publique"
    exit 1
fi

echo "✅ Votre IP publique est: $PUBLIC_IP"
echo ""
echo "Pour autoriser cette IP dans le firewall SQL Azure:"
echo "1. Ajoutez cette ligne dans votre terraform.tfvars:"
echo ""
echo "allowed_ip_addresses = [\"$PUBLIC_IP\"]"
echo ""
echo "2. Ou ajoutez directement via Azure CLI:"
echo ""
echo "az sql server firewall-rule create \\"
echo "  --resource-group \$(terraform output -raw resource_group_name) \\"
echo "  --server \$(terraform output -raw sql_server_name) \\"
echo "  --name MyIP \\"
echo "  --start-ip-address $PUBLIC_IP \\"
echo "  --end-ip-address $PUBLIC_IP"
