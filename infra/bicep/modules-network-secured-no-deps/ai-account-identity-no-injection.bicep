param accountName string
param location string
param modelName string
param modelFormat string
param modelVersion string
param modelSkuName string
param modelCapacity int
param agentSubnetId string
@description('Whether to configure network injection at create time')
param networkInjection bool = true

@description('Use Microsoft-managed network instead of VNet injection')
param useMicrosoftManagedNetwork bool = false

@description('Public network access setting at create time')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessAtCreate string = 'Disabled'


#disable-next-line BCP036
resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: accountName
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: publicNetworkAccessAtCreate
    // networkInjections expects an array of objects
    networkInjections: [
      // {
      //   scenario: 'agent'
      //   useMicrosoftManagedNetwork: false
      //   // When using Microsoft-managed network, omit subnetArmId
      //   subnetArmId: agentSubnetId
      // }
    ]
    // true is not supported today
    disableLocalAuth: false
  }
}

#disable-next-line BCP081
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01'=  {
  parent: account
  name: modelName
  sku : {
    capacity: modelCapacity
    name: modelSkuName
  }
  properties: {
    model:{
      name: modelName
      format: modelFormat
      version: modelVersion
    }
  }
}

output accountName string = account.name
output accountID string = account.id
output accountTarget string = account.properties.endpoint
output accountPrincipalId string = account.identity.principalId
