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

clusterAdminGroupObjectIds=$(az ad group create \
    --display-name ${RESOURCENAME}ClusterAdmin \
    --mail-nickname ${RESOURCENAME}ClusterAdmin \
    --output JSON \
    --query objectId)

az deployment group create \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCEGROUP \
    --template-file ./src/infrastructure/azuredeploy.json \
    --parameters "{ \"name\": {\"value\": \"$RESOURCENAME\"}, \"clusterAdminGroupObjectIds\": {\"value\": [ $clusterAdminGroupObjectIds ]}}"
