/*
This parameter file is used to deploy the private-foundry Bicep module.
Dummy values have been used for any sensitive identifiers and region set to australiaeast (ause).

Usage:
  az deployment group create -g <resource-group-name> --parameters private-foundry.test.bicepparam

Replace <resource-group-name> with your target Azure Resource Group.

Ensure you have the necessary permissions and that the referenced Bicep module and parameter file are accessible.
*/

using './private-foundry-no-deps.bicep'

param location = 'eastus2'
param aiServices = 'privfoundrynodepskv2'
param modelName = 'gpt-4o'
param modelFormat = 'OpenAI'
param modelVersion = '2024-11-20'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 30
param firstProjectName = 'projectnodepskv2'
param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'
param displayName = 'projectnodepskv2'

// Resource IDs for existing resources (DUMMY values)
// If you provide these, the deployment will use the existing resources instead of creating new ones
param existingVnetResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet-example'
param vnetName = 'vnet-example'
param peSubnetName = 'pe-subnet-example'
param agentSubnetName = 'agent-subnet-example'

// Pass the DNS zone map here
// Leave empty to create new DNS zone, add the resource group of existing DNS zone to use it
param existingDnsZones = {
  'privatelink.services.ai.azure.com': 'rg-dns-example'
  'privatelink.openai.azure.com': 'rg-dns-example'
  'privatelink.cognitiveservices.azure.com': 'rg-dns-example'               
                  
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
param vnetAddressPrefix = '10.1.0.0/16'
param peSubnetPrefix = '10.1.3.0/24'
param agentSubnetPrefix = '10.1.4.0/24'
