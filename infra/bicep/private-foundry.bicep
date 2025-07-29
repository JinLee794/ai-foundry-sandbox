/*
  Module: private-foundry.bicep
  Purpose: Deploy AI Services account and GPT-4o model deployment, plus capability host.
  Usage: Use as a parameterized module in your main.bicep or parent module.
*/

@description('Name of the AI account')
param accountName string

@description('Azure region for deployment')
param location string

@description('Model name (e.g., gpt-4o)')
param modelName string

@description('Model format')
param modelFormat string

@description('Model version')
param modelVersion string

@description('Model SKU name')
param modelSkuName string

@description('Model capacity')
param modelCapacity int

@description('Name of the resource group')
param resourceGroupName string

@description('Name of the virtual network')
param virtualNetworkName string

@description('Address prefix for the virtual network')
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for the agent subnet')
param agentSubnetAddressPrefix string

@description('Address prefix for the private endpoint subnet')
param privateEndpointSubnetAddressPrefix string

@description('Name of the agent subnet')
param agentSubnetName string = 'agent-subnet'

@description('Name of the private endpoint subnet')
param privateEndpointSubnetName string = 'pe-subnet'

@description('Project name')
param projectName string

@description('Cosmos DB connection string')
param cosmosDBConnection string = ''

@description('Azure Storage connection string')
param azureStorageConnection string = ''

@description('AI Search connection string')
param aiSearchConnection string = ''

@description('Project capability host')
param projectCapHost string

@description('Unique suffix for resource naming')
param uniqueSuffix string

@description('The display name of the project')
param displayName string = 'network secured agent project'
@description('This project will be a sub-resource of your account')
param projectDescription string = 'A project for the AI Foundry account with network secured deployed Agent'
// // Optional: dependencies as resource IDs or outputs
// @description('Resource ID or output for AI Search')
// param aiSearch object

// @description('Resource ID or output for Storage')
// param storage object

// @description('Resource ID or output for Cosmos DB')
// param cosmosDB object

// @description('Resource ID or output for Private Endpoint and DNS')
// param privateEndpointAndDNS object

// @description('Resource ID or output for Cosmos Account Role Assignments')
// param cosmosAccountRoleAssignments object

// @description('Resource ID or output for Storage Account Role Assignment')
// param storageAccountRoleAssignment object

// @description('Resource ID or output for AI Search Role Assignments')
// param aiSearchRoleAssignments object

module network 'foundry/network.bicep' = {
  name: 'network-${uniqueSuffix}-deployment'
  params: {
    resourceGroupName: resourceGroupName
    virtualNetworkName: virtualNetworkName
    agentSubnetAddressPrefix: agentSubnetAddressPrefix
    privateEndpointSubnetAddressPrefix: privateEndpointSubnetAddressPrefix
    agentSubnetName: agentSubnetName
    privateEndpointSubnetName: privateEndpointSubnetName
  }
}

module aiAccount 'foundry/ai-account-identity.bicep' = {
  name: 'ai-${accountName}-${uniqueSuffix}-deployment'
  params: {
    accountName: accountName
    location: location
    modelName: modelName
    modelFormat: modelFormat
    modelVersion: modelVersion
    modelSkuName: modelSkuName
    modelCapacity: modelCapacity
    agentSubnetId: network.outputs.agentSubnetId
  }
}

module aiProject 'foundry/ai-project-identity.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    projectName: projectName
    projectDescription: projectDescription
    displayName: displayName
    location: location

    // aiSearchName: aiDependencies.outputs.aiSearchName
    // aiSearchServiceResourceGroupName: aiDependencies.outputs.aiSearchServiceResourceGroupName
    // aiSearchServiceSubscriptionId: aiDependencies.outputs.aiSearchServiceSubscriptionId

    // cosmosDBName: aiDependencies.outputs.cosmosDBName
    // cosmosDBSubscriptionId: aiDependencies.outputs.cosmosDBSubscriptionId
    // cosmosDBResourceGroupName: aiDependencies.outputs.cosmosDBResourceGroupName

    // azureStorageName: aiDependencies.outputs.azureStorageName
    // azureStorageSubscriptionId: aiDependencies.outputs.azureStorageSubscriptionId
    // azureStorageResourceGroupName: aiDependencies.outputs.azureStorageResourceGroupName
    // dependent resources
    accountName: aiAccount.outputs.accountName
  }
  dependsOn: [
    //  privateEndpointAndDNS
    //  cosmosDB
    //  aiSearch
    //  storage
  ]
}

module addProjectCapabilityHost 'foundry/add-project-capability-host.bicep' = {
  name: 'capabilityHost-configuration-${uniqueSuffix}-deployment'
  params: {
    accountName: aiAccount.outputs.accountName
    projectName: aiProject.outputs.projectName
    cosmosDBConnection: cosmosDBConnection
    azureStorageConnection: azureStorageConnection
    aiSearchConnection: aiSearchConnection
    projectCapHost: projectCapHost
  }
  dependsOn: [
    // aiSearch
    // storage
    // cosmosDB
    // privateEndpointAndDNS
    // cosmosAccountRoleAssignments
    // storageAccountRoleAssignment
    // aiSearchRoleAssignments
  ]
}
