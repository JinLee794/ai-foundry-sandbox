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
param agentSubnetName = 'agent-subnet-demo'
