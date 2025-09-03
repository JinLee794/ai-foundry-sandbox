/*
This parameter file is used to deploy the private-foundry Bicep module.

Usage:
  az deployment group create -g <resource-group-name> --parameters private-foundry.test.bicepparam

Replace <resource-group-name> with your target Azure Resource Group.

Ensure you have the necessary permissions and that the referenced Bicep module and parameter file are accessible.
*/

using './private-foundry-no-deps.bicep'

param location = 'eastus2'
param aiServices = 'privfoundrynodepskv'
param modelName = 'gpt-4o'
param modelFormat = 'OpenAI'
param modelVersion = '2024-11-20'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 30
param firstProjectName = 'projectnodepskv'
param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'
param displayName = 'projectnodepskv'

// Resource IDs for existing resources
// If you provide these, the deployment will use the existing resources instead of creating new ones
param existingVnetResourceId = '/subscriptions/63862159-43c8-47f7-9f6f-6c63d56b0e17/resourceGroups/ai-priv-foundry-sandbox/providers/Microsoft.Network/virtualNetworks/priv-foundry-sandbox'
param vnetName = 'priv-foundry-sandbox'
param peSubnetName = 'pe-subnet-nd'
param agentSubnetName = 'agent-subnet-nd'

// Pass the DNS zone map here
// Leave empty to create new DNS zone, add the resource group of existing DNS zone to use it
param existingDnsZones = {
  'privatelink.services.ai.azure.com': 'ai-foundry-test'
  'privatelink.openai.azure.com': 'ai-foundry-test'
  'privatelink.cognitiveservices.azure.com': 'ai-foundry-test'               
                  
}

//DNSZones names for validating if they exist
param dnsZoneNames = [
  'privatelink.services.ai.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.cognitiveservices.azure.com'
]

// Network configuration: only used when existingVnetResourceId is not provided
// These addresses are only used when creating a new VNet and subnets
// If you provide existingVnetResourceId, these values will be ignored
param vnetAddressPrefix = ''
param peSubnetPrefix = '10.0.3.0/24'
param agentSubnetPrefix = '10.0.4.0/24'
