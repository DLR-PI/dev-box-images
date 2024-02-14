var settings = loadJsonContent('main.parameters.json')
param location string = resourceGroup().location
param deploymentId string = newGuid()

module identity '../templates/identity/main.bicep' = {
  name: 'deploy-identity-${deploymentId}'
  params: {
    name: settings.identityName
    location: location
  }
}

resource gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: settings.galleryName
  location: location
  properties: {}
}

var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource roleAssignmentsContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.name, 'Contributor')
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: identity.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}


module networkModule '../templates/network/main.bicep' = {
  name: 'deploy-network-${deploymentId}'
  params: {
    name: settings.network.name
    subnetName: settings.network.subnetName
    location: location
    vnetAddressPrefix: settings.network.vnetAddressPrefix
    defaultSubnetAddressPrefix : settings.network.defaultSubnetAddressPrefix
    networkSecurityGroup: {}
    delegations: [
      {
        name: 'Microsoft.ContainerInstance/containerGroups'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}

module storageModule '../templates/storage/main.bicep' = {
  name: guid('deploy-storage-${deploymentId}')
  params: {
    name: settings.storage.name
    sku: settings.storage.sku
    kind: settings.storage.kind
    location: location
  }
}
