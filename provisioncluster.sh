export SUBSCRIPTION="Customer"
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
    --template-file ./src/infrastructure/azuredeploy.json \
    --parameters name=$RESOURCENAME
