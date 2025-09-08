@description('Name of the virtual network')
param vnetName string

@description('Name of the subnet')
param subnetName string

@description('Address prefix for the subnet')
param addressPrefix string

@description('Array of subnet delegations')
param delegations array = []

@description('Disable private endpoint network policies on this subnet')
param disablePrivateEndpointNetworkPolicies bool = false

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: addressPrefix
    delegations: delegations
    // Only set when requested (for private endpoint subnets)
    privateEndpointNetworkPolicies: disablePrivateEndpointNetworkPolicies ? 'Disabled' : 'Enabled'
  }
}

output subnetId string = subnet.id
output subnetName string = subnetName
