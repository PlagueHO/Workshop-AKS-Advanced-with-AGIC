export SUBSCRIPTION="c7f8ca1e-46f6-4a59-a039-15eaefd2337e"
export RESOURCEGROUP="dsr-kube-rg"
export RESOURCENAME="dsrkube"
export LOCATION="eastus"

az feature register \
    --subscription $SUBSCRIPTION \
    --name AAD-V2 \
    --namespace Microsoft.ContainerService

az provider register \
     --subscription $SUBSCRIPTION \
     --name Microsoft.ContainerService

az group create \
    --subscription $SUBSCRIPTION \
    --name $RESOURCEGROUP \
    --location $LOCATION

az deployment group create \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCEGROUP \
    --template-file azuredeploy.json \
    --parameters name=$RESOURCENAME
