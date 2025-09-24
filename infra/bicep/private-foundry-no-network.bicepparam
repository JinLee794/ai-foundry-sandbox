/*
This parameter file is used to deploy the private-foundry Bicep module.

Usage:
  az deployment group create -g <resource-group-name> --parameters private-foundry.test.bicepparam

Replace <resource-group-name> with your target Azure Resource Group.

Ensure you have the necessary permissions and that the referenced Bicep module and parameter file are accessible.
*/

using './private-foundry-no-network.bicep'

param location = 'eastus2'
param aiServices = 'praifoundryjinlenonw2'
param modelName = 'gpt-4o'
param modelFormat = 'OpenAI'
param modelVersion = '2024-11-20'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 30
param firstProjectName = 'praifoundryjinlenonwproj2'
param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'
param displayName = 'privAIFoundryJinLENoNWProject2'

// Resource IDs for existing resources
param existingVnetResourceId = '/subscriptions/63862159-43c8-47f7-9f6f-6c63d56b0e17/resourceGroups/ai-priv-foundry-sandbox/providers/Microsoft.Network/virtualNetworks/priv-foundry-sandbox'
param vnetName = 'priv-foundry-sandbox'
param agentSubnetName = 'manual-agent-subnet'

param cosmosDBName = 'privfoundrycosmosdb'
param aiSearchName = 'privfoundryaisearch'
param azureStorageName = 'privfoundrystorage'

param userAssignedIdentityResourceId = '/subscriptions/63862159-43c8-47f7-9f6f-6c63d56b0e17/resourceGroups/ai-priv-foundry-sandbox/providers/Microsoft.ManagedIdentity/userAssignedIdentities/priv-foundry-identity'
