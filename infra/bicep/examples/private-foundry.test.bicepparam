using '../private-foundry.bicep'

// AI Account Configuration
param accountName = 'priv-aifoundry-test'
param location = 'eastus2'

// Model Configuration
param modelName = 'gpt-4o'
param modelFormat = 'OpenAI'
param modelVersion = '2024-08-06'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 10

// Network Configuration
param resourceGroupName = 'Shared'
param virtualNetworkName = 'ai-foundry-private-vnet-test'
param virtualNetworkAddressPrefix = '10.0.0.0/16'
param agentSubnetAddressPrefix = '10.0.1.0/24'
param privateEndpointSubnetAddressPrefix = '10.0.2.0/24'
param agentSubnetName = 'agent-subnet'
param privateEndpointSubnetName = 'pe-subnet'

// Project Configuration
param projectName = 'test-project'
param projectCapHost = 'test-capability-host'

// Connection Strings (dummy values for testing)
// param cosmosDBConnection = 'AccountEndpoint=https://test-cosmos.documents.azure.com:443/;AccountKey=dummy-key-for-testing=='
// param azureStorageConnection = 'DefaultEndpointsProtocol=https;AccountName=teststorage;AccountKey=dummy-key-for-testing==;EndpointSuffix=core.windows.net'
// param aiSearchConnection = 'https://test-search.search.windows.net;dummy-api-key-for-testing'

// Unique suffix for resource naming
param uniqueSuffix = 'test001'
