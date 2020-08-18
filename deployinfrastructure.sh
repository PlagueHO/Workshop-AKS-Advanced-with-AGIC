#!/bin/sh
export RESOURCEGROUPNAME="kubernetes-rg"
export RESOURCENAME="mykube"
export LOCATION="eastus"
export ACTION="create"

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
    --template-file ./src/infrastructure/azuredeploy.json \
    --parameters "{ \"name\": {\"value\": \"$RESOURCENAME\"}, \"clusterAdminGroupObjectIds\": {\"value\": [ $clusterAdminGroupObjectIds ]}}"
