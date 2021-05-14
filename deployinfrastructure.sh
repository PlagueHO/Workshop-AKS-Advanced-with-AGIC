#!/bin/sh
export BASERESOURCENAME="mykube"
export LOCATION="eastus"
export ACTION="create"
export METHOD="ARM"
# export TEMPLATEFILE="./src/infrastructure/main.bicep"

RESOURCEGROUPNAME="${BASERESOURCENAME}-${METHOD,,}-rg"
RESOURCENAME="${BASERESOURCENAME}${METHOD,,}"

if [ ${METHOD} = 'ARM' ]; then
    TEMPLATEFILE="./src/infrastructure/azuredeploy.json"
else
    TEMPLATEFILE="./src/infrastructure/main.bicep"
fi

az provider register \
     --name Microsoft.ContainerService

az feature register \
    --name AAD-V2 \
    --namespace Microsoft.ContainerService

clusterAdminGroupObjectIds=$(az ad group create \
    --display-name ${RESOURCENAME}ClusterAdmin \
    --mail-nickname ${RESOURCENAME}ClusterAdmin \
    --output JSON \
    --query objectId)

az group create \
    --name $RESOURCEGROUPNAME \
    --location $LOCATION

az deployment group $ACTION \
    --resource-group $RESOURCEGROUPNAME \
    --template-file $TEMPLATEFILE \
    --parameters "{ \"name\": {\"value\": \"$RESOURCENAME\"}, \"clusterAdminGroupObjectIds\": {\"value\": [ $clusterAdminGroupObjectIds ]}}"
