#! /bin/sh

for filename in "azurecr.io" "blob.core.windows.net" "database.azure.com" "privatelink.eastus.azmk8s.io" "privatelink.vaultcore.azure.net" "redis.azure.net" "vault.azure.net"; do
    sed -i '' 's/60/62/g' /etc/resolver/$filename
done
