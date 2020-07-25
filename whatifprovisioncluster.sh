export SUBSCRIPTION="Customer"
export RESOURCEGROUP="dsr-kube-rg"
export RESOURCENAME="dsrkubey"
export LOCATION="eastus"

az group create \
    --subscription $SUBSCRIPTION \
    --name $RESOURCEGROUP \
    --location $LOCATION

az deployment group what-if \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCEGROUP \
    --template-file ./src/infrastructure/azuredeploy.json \
    --parameters name=$RESOURCENAME
