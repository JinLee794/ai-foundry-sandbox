/*
Standard Setup Network Secured Steps for main.bicep
-----------------------------------
*/
@description('Location for all resources.')
@allowed([
    'australiaeast'
    'eastus'
    'eastus2'
    'francecentral'
    'japaneast'
    'norwayeast'
    'southindia'
    'swedencentral'
    'uaenorth'
    'uksouth'
    'westus'
    'westus3'
    'westus2'
  ])
param location string = 'eastus2'

@description('Name for your AI Services resource.')
param aiServices string = 'aiservices'

// Model deployment parameters
@description('The name of the model you want to deploy')
param modelName string = 'gpt-4o'
@description('The provider of your model')
param modelFormat string = 'OpenAI'
@description('The version of your model')
param modelVersion string = '2024-11-20'
@description('The sku of your model deployment')
param modelSkuName string = 'GlobalStandard'
@description('The tokens per minute (TPM) of your model deployment')
param modelCapacity int = 30

// Create a short, unique suffix, that will be unique to each resource group
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)
var accountName = toLower('${aiServices}${uniqueSuffix}')

@description('The name of the project capability host to be created')
param projectCapHostName string = 'caphostproj'

@description('Name for your project resource.')
param firstProjectName string = 'project'

@description('This project will be a sub-resource of your account')
param projectDescription string = 'A project for the AI Foundry account with network secured deployed Agent'

@description('The display name of the project')
param displayName string = 'network secured agent project'

// Existing Virtual Network parameters
@description('Virtual Network name for the Agent to create new or existing virtual network')
param vnetName string = 'agent-vnet-test'

@description('The name of Agents Subnet to create new or existing subnet for agents')
param agentSubnetName string = 'agent-subnet'

// @description('The name of Private Endpoint subnet to create new or existing subnet for private endpoints')
// param peSubnetName string = 'pe-subnet'

//Existing standard Agent required resources
@description('Existing Virtual Network name Resource ID')
param existingVnetResourceId string = ''

@description('Public network access setting during account creation')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessAtCreate string = 'Disabled'

@description('Use Microsoft-managed network instead of VNet injection for the AI account')
param useMicrosoftManagedNetwork bool = false

@description('Whether to configure network injection at create time')
param networkInjection bool = true


var projectName = toLower('${firstProjectName}${uniqueSuffix}')

var existingVnetPassedIn = existingVnetResourceId != ''


var vnetParts = split(existingVnetResourceId, '/')
var existingVnetName = existingVnetPassedIn ? last(vnetParts) : vnetName
var trimVnetName = trim(existingVnetName)

var agentSubnetId = existingVnetPassedIn ? '${existingVnetResourceId}/subnets/${agentSubnetName}' : resourceId('Microsoft.Network/virtualNetworks/subnets', trimVnetName, agentSubnetName)


/*
  Create the AI Services account and gpt-4o model deployment
*/
module aiAccount 'modules-network-secured/ai-account-identity.bicep' = {
  name: 'ai-${accountName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    accountName: accountName
    location: location
    modelName: modelName
    modelFormat: modelFormat
    modelVersion: modelVersion
    modelSkuName: modelSkuName
    modelCapacity: modelCapacity
    agentSubnetId: agentSubnetId
    publicNetworkAccessAtCreate: publicNetworkAccessAtCreate
    useMicrosoftManagedNetwork: useMicrosoftManagedNetwork
    networkInjection: networkInjection
  }
}

/*
  Creates a new project (sub-resource of the AI Services account)
*/
module aiProject 'modules-network-secured-no-deps/ai-project-identity.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    projectName: projectName
    projectDescription: projectDescription
    displayName: displayName
    location: location

    accountName: aiAccount.outputs.accountName
  }
  dependsOn: [
  ]
}

// // This module creates the capability host for the project and account
// REQUIRES vectorStoreConnections:
// "message": "CreateCapabilityHostRequestDto is invalid: Agents CapabilityHost supports a single, non empty value for vectorStoreConnections property.; Agents CapabilityHost supports a single, non empty value for storageConnections property.; Agents CapabilityHost supports a single, non empty value for threadStorageConnections property.",

// module addProjectCapabilityHost 'modules-network-secured/add-project-capability-host.bicep' = {
//   name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
//   params: {
//     accountName: aiAccount.outputs.accountName
//     projectName: aiProject.outputs.projectName
//     projectCapHost: '${projectName}-caphost'
//   }
//   dependsOn: [
//     aiProject
//     //  aiSearch      // Ensure AI Search exists
//     //  storage       // Ensure Storage exists
//     //  cosmosDB
//     //  privateEndpointAndDNS
//     //  cosmosAccountRoleAssignments
//     //  storageAccountRoleAssignment
//     //  aiSearchRoleAssignments
//   ]
// }
