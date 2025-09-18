/*
This parameter file is used to deploy the private-foundry Bicep module.

Usage:
  az deployment group create -g <resource-group-name> --parameters private-foundry.test.bicepparam

Replace <resource-group-name> with your target Azure Resource Group.

Ensure you have the necessary permissions and that the referenced Bicep module and parameter file are accessible.
*/
using './private-foundry-no-network.bicep'

param location = 'eastus'
param aiServices = 'demo-ai-services'
param modelName = 'gpt-demo'
param modelFormat = 'OpenAI'
param modelVersion = '2024-11-20'
param modelSkuName = 'DemoStandard'
param modelCapacity = 1
param firstProjectName = 'demo-project-01'
param projectDescription = 'Demo project for the AI Foundry account with network secured deployed Agent'
param displayName = 'DemoFoundryProject01'

// Resource IDs for existing resources (dummy values)
param existingVnetResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet'
param vnetName = 'demo-vnet'
param peSubnetName = 'pe-subnet-demo'
param agentSubnetName = 'agent-subnet-demo'
