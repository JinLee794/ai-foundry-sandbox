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

param userAssignedIdentityResourceId string

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
// module aiProject 'modules-network-secured-no-deps/ai-project-identity.bicep' = {
//   name: 'ai-${projectName}-${uniqueSuffix}-deployment'
//   params: {
//     // workspace organization
//     projectName: projectName
//     projectDescription: projectDescription
//     displayName: displayName
//     location: location

//     accountName: aiAccount.outputs.accountName
//   }
//   dependsOn: [
//   ]
// }

// ==================================================================
//  pt.2, creating project connections to existing resources
//

param azureStorageName string 
param aiSearchName string
param cosmosDBName string

// resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
//   name: azureStorageName
//   scope: resourceGroup()
// }

// resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' existing = {
//   name: aiSearchName
//   scope: resourceGroup()
// }

// resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
//   name:  cosmosDBName
//   scope: resourceGroup()
// }


module aiProject 'modules-network-secured/ai-project-identity.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    projectName: projectName
    projectDescription: projectDescription
    displayName: displayName
    location: location
    aiSearchName: aiSearchName
    aiSearchServiceResourceGroupName: resourceGroup().name
    aiSearchServiceSubscriptionId: subscription().subscriptionId

    userAssignedIdentityResourceId: userAssignedIdentityResourceId
    cosmosDBName: cosmosDBName
    cosmosDBSubscriptionId: subscription().subscriptionId
    cosmosDBResourceGroupName: resourceGroup().name
    azureStorageName: azureStorageName
    azureStorageSubscriptionId: subscription().subscriptionId
    azureStorageResourceGroupName: resourceGroup().name
    accountName: aiAccount.outputs.accountName
  }
  dependsOn: [
  ]
}


// This module creates the capability host for the project and account
module addProjectCapabilityHost 'modules-network-secured/add-project-capability-host.bicep' = {
  name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
  params: {
    accountName: aiAccount.outputs.accountName
    projectName: aiProject.outputs.projectName

    cosmosDBConnection: aiProject.outputs.cosmosDBConnection
    azureStorageConnection: aiProject.outputs.azureStorageConnection
    aiSearchConnection: aiProject.outputs.aiSearchConnection
    projectCapHost: projectCapHostName
  }
  dependsOn: [
  ]
}


// module formatProjectWorkspaceId 'modules-network-secured/format-project-workspace-id.bicep' = {
//   name: 'format-project-workspace-id-${uniqueSuffix}-deployment'
//   params: {
//     projectWorkspaceId: aiProject.outputs.projectWorkspaceId
//   }
// }

// /*
//   Assigns the project SMI the storage blob data contributor role on the storage account
// */
// module storageAccountRoleAssignment 'modules-network-secured/azure-storage-account-role-assignment.bicep' = {
//   name: 'storage-${azureStorageName}-${uniqueSuffix}-deployment'
//   scope: resourceGroup()
//   params: {
//     azureStorageName: azureStorageName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//    storage
//   ]
// }

// // The Comos DB Operator role must be assigned before the caphost is created
// module cosmosAccountRoleAssignments 'modules-network-secured/cosmosdb-account-role-assignment.bicep' = {
//   name: 'cosmos-account-ra-${projectName}-${uniqueSuffix}-deployment'
//   scope: resourceGroup()
//   params: {
//     cosmosDBName: cosmosDBName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     cosmosDB
//   ]
// }

// // This role can be assigned before or after the caphost is created
// module aiSearchRoleAssignments 'modules-network-secured/ai-search-role-assignments.bicep' = {
//   name: 'ai-search-ra-${projectName}-${uniqueSuffix}-deployment'
//   scope: resourceGroup()
//   params: {
//     aiSearchName: aiSearchName
//     projectPrincipalId: aiProject.outputs.projectPrincipalId
//   }
//   dependsOn: [
//     aiSearch
//   ]
// }

// // The Storage Blob Data Owner role must be assigned after the caphost is created
// module storageContainersRoleAssignment 'modules-network-secured/blob-storage-container-role-assignments.bicep' = {
//   name: 'storage-containers-${uniqueSuffix}-deployment'
//   scope: resourceGroup()
//   params: {
//     aiProjectPrincipalId: aiProject.outputs.projectPrincipalId
//     storageName: azureStorageName
//     workspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
//   }
//   dependsOn: [
//     addProjectCapabilityHost
//   ]
// }

// // The Cosmos Built-In Data Contributor role must be assigned after the caphost is created
// module cosmosContainerRoleAssignments 'modules-network-secured/cosmos-container-role-assignments.bicep' = {
//   name: 'cosmos-ra-${uniqueSuffix}-deployment'
//   scope: resourceGroup()
//   params: {
//     cosmosAccountName: cosmosDBName
//     projectWorkspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
//     projectPrincipalId: aiProject.outputs.projectPrincipalId

//   }
//   dependsOn: [
//     addProjectCapabilityHost
//     storageContainersRoleAssignment
//   ]
// }
