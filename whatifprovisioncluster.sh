export SUBSCRIPTION="Customer"
export RESOURCEGROUP="dsr-kube-rg"
export RESOURCENAME="dsrkubey"
export LOCATION="eastus"

az group create \
    --subscription $SUBSCRIPTION \
    --name $RESOURCEGROUP \
    --location $LOCATION

clusterAdminGroupObjectIds=$(az ad group create \
    --display-name ${RESOURCENAME}ClusterAdmin \
    --mail-nickname ${RESOURCENAME}ClusterAdmin \
    --output JSON \
    --query objectId)

az deployment group what-if \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCEGROUP \
    --template-file ./src/infrastructure/azuredeploy.json \
    --parameters name=$RESOURCENAME clusterAdminGroupObjectIds=$clusterAdminGroupObjectIds
