export SUBSCRIPTION="c7f8ca1e-46f6-4a59-a039-15eaefd2337e"
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
    --template-file azuredeploy.json \
    --parameters name=$RESOURCENAME
