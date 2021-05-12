#!/bin/sh
export RESOURCEGROUPNAME="kubernetes-rg"
export RESOURCENAME="mykube"
export LOCATION="eastus"
export ACTION="create"
export TEMPLATEFILE="./src/infrastructure/azuredeploy.json"
# export TEMPLATEFILE="./src/infrastructure/main.bicep"

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
