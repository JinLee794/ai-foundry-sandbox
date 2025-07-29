@description('Name of the resource group')
param resourceGroupName string

@description('Name of the virtual network')
param virtualNetworkName string

@description('Address prefix for the agent subnet')
param agentSubnetAddressPrefix string

@description('Address prefix for the private endpoint subnet')
param privateEndpointSubnetAddressPrefix string

@description('Name of the agent subnet')
param agentSubnetName string = 'agent-subnet'

@description('Name of the private endpoint subnet')
param privateEndpointSubnetName string = 'pe-subnet'

resource agentSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: '${virtualNetworkName}/${agentSubnetName}'
  properties: {
    addressPrefix: agentSubnetAddressPrefix
    delegations: [
      {
        name: 'Microsoft.App/environments'
        properties: {
          serviceName: 'Microsoft.App/environments'
        }
      }
    ]
  }
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: '${virtualNetworkName}/${privateEndpointSubnetName}'
  properties: {
    addressPrefix: privateEndpointSubnetAddressPrefix
  }
}

@description('Resource ID of the agent subnet')
output agentSubnetId string = agentSubnet.id

@description('Resource ID of the private endpoint subnet')
output peSubnetId string = peSubnet.id
