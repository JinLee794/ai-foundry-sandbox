/*
This parameter file is used to deploy the private-foundry Bicep module.

Usage:
  az deployment group create -g <resource-group-name> --parameters private-foundry.test.bicepparam

Replace <resource-group-name> with your target Azure Resource Group.

Ensure you have the necessary permissions and that the referenced Bicep module and parameter file are accessible.
*/

using './private-foundry.bicep'

param location = 'eastus2'
param aiServices = 'privfoundry'
param modelName = 'gpt-4o'
param modelFormat = 'OpenAI'
param modelVersion = '2024-11-20'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 30
param firstProjectName = 'project'
param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'
param displayName = 'project'

// Resource IDs for existing resources
// If you provide these, the deployment will use the existing resources instead of creating new ones
param existingVnetResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-placeholder/providers/Microsoft.Network/virtualNetworks/vnet-placeholder'
param vnetName = 'vnet-placeholder'
param peSubnetName = 'pe-subnet'
param agentSubnetName = 'agent-subnet'
param aiSearchResourceId = ''
param azureStorageAccountResourceId = ''
param azureCosmosDBAccountResourceId = ''
// Pass the DNS zone map here
// Leave empty to create new DNS zone, add the resource group of existing DNS zone to use it
param existingDnsZones = {
  'privatelink.services.ai.azure.com': ''
  'privatelink.openai.azure.com': ''
  'privatelink.cognitiveservices.azure.com': ''               
  'privatelink.search.windows.net': ''           
  'privatelink.blob.core.windows.net': ''                            
  'privatelink.documents.azure.com': ''                      
}

//DNSZones names for validating if they exist
param dnsZoneNames = [
  'privatelink.services.ai.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.search.windows.net'
  'privatelink.blob.core.windows.net'
  'privatelink.documents.azure.com'
]


// Network configuration: only used when existingVnetResourceId is not provided
// These addresses are only used when creating a new VNet and subnets
// If you provide existingVnetResourceId, these values will be ignored
param vnetAddressPrefix = ''
param agentSubnetPrefix = '10.0.1.0/24'
param peSubnetPrefix = '10.0.2.0/24'
