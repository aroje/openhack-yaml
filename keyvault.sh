CLIENTID=67354fde-9231-4931-8580-960912f9d25f
CLIENTSECRET=2c24aa11-ab58-4356-9548-db3bfa8331b5
SQLUSR=sqladmin9Cv6941
SQLPWD=pC3kn9T85
KV_NAME=aks010kv

#Create key vault
az keyvault create -n aks010kv -g teamResources --sku premium

#Deploy Key Vault FlexVolume to AKS cluster
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

#Validate Key Vault FlexVolume is running as expected
kubectl get pods -n kv
#Should be 3 pods

#Add your service principal credentials as Kubernetes secrets accessible by the Key Vault FlexVolume driver
kubectl create secret generic cluspncreds --from-literal clientid=$CLIENTID --from-literal clientsecret=$CLIENTSECRET --type=azure/kv

# Assign key vault permissions to service principal
az keyvault set-policy -n $KV_NAME --key-permissions get --spn $CLIENTID
az keyvault set-policy -n $KV_NAME --secret-permissions get --spn $CLIENTID
az keyvault set-policy -n $KV_NAME --certificate-permissions get --spn $CLIENTID

#Add our SQL credentials as a secret to key vault
#not working due to underscore, just used sqlusr and sqlpwd for now in what i've run
az keyvault secret set -n SQL_USER --vault-name aks010kv --value $SQLUSR
az keyvault secret set -n SQL_PASSWORD --vault-name aks010kv --value $SQLPWD