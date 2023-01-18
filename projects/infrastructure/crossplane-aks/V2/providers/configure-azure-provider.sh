#!/bin/sh
echo "export your azure subscription id to env"
export SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "create a service principal in azure"
az ad sp create-for-rbac --sdk-auth --role Owner --scopes /subscriptions/$SUBSCRIPTION_ID --name servicePrincipalCrossplanePoC > providers/crossplane-azure-provider-key.json
echo "create azure provider secret"
kubectl create secret generic azure-account-creds -n upbound-system --from-file=credentials=./providers/crossplane-azure-provider-key.json
echo "export azure client id"
export AZURE_CLIENT_ID=$(cat providers/crossplane-azure-provider-key.json | jq -r '.clientId')
echo "add required Azure Active Directory permissions"
az ad app permission add --id ${AZURE_CLIENT_ID} --api 00000002-0000-0000-c000-000000000000 --api-permissions 1cda74f2-2616-4834-b122-5cb1b07f8a59=Role 78c8a3c8-a07e-4b9e-af1b-b5ccab50a175=Role
echo "grant (activate) the permissions"
az ad app permission grant --id ${AZURE_CLIENT_ID} --api 00000002-0000-0000-c000-000000000000 --scope /subscriptions/$SUBSCRIPTION_ID
echo "grant admin consent to the service princinpal you created (The admin consent workflow gives admins a secure way to grant access to applications that require admin approval)"
az ad app permission admin-consent --id "${AZURE_CLIENT_ID}"
echo "install crossplane azure provider"
kubectl apply -f provider-azure.yaml
echo "install crossplane helm provider"
kubectl apply -f provider-helm.yaml
echo "check for the installed providers"
kubectl get provider
echo "wait for right deployment condition (provider azure healthy and running)"
kubectl wait --for=condition=healthy --timeout=120s provider/provider-azure
echo "apply the azure provider configuration"
kubectl apply -f azure-default-provider-config.yaml
# echo "apply the helm provider configuration"
# kubectl apply -f helm-provider.yml
