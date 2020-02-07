CLIENTID=67354fde-9231-4931-8580-960912f9d25f
CLIENTSECRET=2c24aa11-ab58-4356-9548-db3bfa8331b5
SQLUSR=sqladmin9Cv6941
SQLPWD=pC3kn9T85
KV_NAME=aks010kv
SUBSCRIPTION=ae235c5e-7998-4b1d-9a67-40dfcab3f663
RES_GROUP=teamResources

#Create key vault
az keyvault create -n aks010kv -g teamResources --sku premium

#Deploy Key Vault FlexVolume to AKS cluster
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

#Validate Key Vault FlexVolume is running as expected
kubectl get pods -n kv
#Should be 3 pods

#Add your service principal credentials as Kubernetes secrets accessible by the Key Vault FlexVolume driver
kubectl create secret generic cluspncreds --from-literal clientid=$CLIENTID --from-literal \
clientsecret=$CLIENTSECRET --type=azure/kv --namespace api-dev

# [Required for version < v0.0.13] Assign Reader Role to the service principal for your keyvault
az role assignment create --role Reader --assignee $CLIENTID \
--scope /subscriptions/$SUBSCRIPTION/resourcegroups/$RES_GROUP/providers/Microsoft.KeyVault/vaults/$KV_NAME

# Assign key vault permissions to service principal
az keyvault set-policy -n $KV_NAME --key-permissions get --spn $CLIENTID
az keyvault set-policy -n $KV_NAME --secret-permissions get --spn $CLIENTID
az keyvault set-policy -n $KV_NAME --certificate-permissions get --spn $CLIENTID

#Add our SQL credentials as a secret to key vault
#not working due to underscore, just used sqlusr and sqlpwd for now in what i've run
az keyvault secret set -n SQLUSER --vault-name aks010kv --value $SQLUSR
az keyvault secret set -n SQLPASSWORD --vault-name aks010kv --value $SQLPWD
