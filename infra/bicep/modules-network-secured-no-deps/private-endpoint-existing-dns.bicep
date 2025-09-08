/*
Private Endpoint (Existing DNS Only)
------------------------------------
Creates private endpoints and attaches DNS zone groups by referencing
existing Private DNS zones that are already linked to the target VNet.

This module DOES:
- Create Private Endpoints for Azure AI Foundry account
- Create Private DNS Zone Groups on the Private Endpoint(s)
  using existing DNS zones

This module DOES NOT:
- Create Private DNS Zones
- Create VNet links for DNS zones
- Create VNets or Subnets

Prerequisites:
- Target VNet and Private Endpoint subnet exist
- The following Private DNS zones exist and are linked to the VNet:
  - privatelink.services.ai.azure.com
  - privatelink.openai.azure.com
  - privatelink.cognitiveservices.azure.com
*/

// --------------------------- Parameters ---------------------------
@description('Name of the AI Foundry account')
param aiAccountName string

@description('Name of the Virtual Network')
param vnetName string

@description('Name of the Private Endpoint subnet')
param peSubnetName string

@description('Suffix for unique resource names')
param suffix string

@description('Resource Group name for existing Virtual Network (if different from current resource group)')
param vnetResourceGroupName string = resourceGroup().name

@description('Subscription ID for Virtual Network')
param vnetSubscriptionId string = subscription().subscriptionId

@description('Map of DNS zone FQDNs to resource group names where the zones exist and are already VNet-linked')
param existingDnsZones object

// ----------------------- Existing Resources ----------------------
resource aiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiAccountName
  scope: resourceGroup()
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetSubscriptionId, vnetResourceGroupName)
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: peSubnetName
}

// ------------------ AI Foundry Private Endpoint ------------------
resource aiAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${aiAccountName}-private-endpoint-${suffix}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: peSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${aiAccountName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: aiAccount.id
          groupIds: [ 'account' ]
        }
      }
    ]
  }
}

// ---------------------- Existing DNS Zones -----------------------
var aiServicesDnsZoneName = 'privatelink.services.ai.azure.com'
var openAiDnsZoneName = 'privatelink.openai.azure.com'
var cognitiveServicesDnsZoneName = 'privatelink.cognitiveservices.azure.com'

// Resource group names for the existing zones (must be provided)
var aiServicesDnsZoneRG = existingDnsZones[aiServicesDnsZoneName]
var openAiDnsZoneRG = existingDnsZones[openAiDnsZoneName]
var cognitiveServicesDnsZoneRG = existingDnsZones[cognitiveServicesDnsZoneName]

// Existing DNS zone references
resource existingAiServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: aiServicesDnsZoneName
  scope: resourceGroup(aiServicesDnsZoneRG)
}

resource existingOpenAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: openAiDnsZoneName
  scope: resourceGroup(openAiDnsZoneRG)
}

resource existingCognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: cognitiveServicesDnsZoneName
  scope: resourceGroup(cognitiveServicesDnsZoneRG)
}

// -------------------- Private DNS Zone Group ---------------------
resource aiServicesDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: aiAccountPrivateEndpoint
  name: '${aiAccountName}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${aiAccountName}-dns-aiserv-config'
        properties: {
          privateDnsZoneId: existingAiServicesPrivateDnsZone.id
        }
      }
      {
        name: '${aiAccountName}-dns-openai-config'
        properties: {
          privateDnsZoneId: existingOpenAiPrivateDnsZone.id
        }
      }
      {
        name: '${aiAccountName}-dns-cogserv-config'
        properties: {
          privateDnsZoneId: existingCognitiveServicesPrivateDnsZone.id
        }
      }
    ]
  }
}

// --------------------------- Outputs -----------------------------
@description('Resource ID of the AI Account Private Endpoint')
output aiAccountPrivateEndpointId string = aiAccountPrivateEndpoint.id

@description('Name of the AI Account Private Endpoint')
output aiAccountPrivateEndpointName string = aiAccountPrivateEndpoint.name

@description('Private IP address of the AI Account Private Endpoint')
output aiAccountPrivateEndpointIP string = aiAccountPrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]

