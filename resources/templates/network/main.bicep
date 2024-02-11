param name string
param location string
param vnetAddressPrefix string
param defaultSubnetAddressPrefix string
param subnetName string
param delegations array
param networkSecurityGroup object

var isNetworkSecurityGroup = networkSecurityGroup != {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: union({
          addressPrefix: defaultSubnetAddressPrefix
          delegations: delegations
        }, isNetworkSecurityGroup ? {
          networkSecurityGroup: networkSecurityGroup
        }: {})
      }
    ]
  }
}

output subnetId string = virtualNetwork.properties.subnets[0].id
