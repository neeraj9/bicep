param name string
param accounts array
param index int

// single resource
resource singleResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: '${name}single-resource-name'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// resource collection
resource storageAccounts 'Microsoft.Storage/storageAccounts@2019-06-01' = [for account in accounts: {
  name: '${name}-collection-${account.name}'
  location: account.location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  dependsOn: [
    singleResource
  ]
}]

// special case property access
output indexedCollectionBlobEndpoint string = storageAccounts[index].properties.primaryEndpoints.blob
output indexedCollectionName string = storageAccounts[index].name
output indexedCollectionId string = storageAccounts[index].id
output indexedCollectionType string = storageAccounts[index].type
output indexedCollectionVersion string = storageAccounts[index].apiVersion

// general case property access
output indexedCollectionIdentity object = storageAccounts[index].identity

// indexed access of two properties
output indexedEndpointPair object = {
  primary: storageAccounts[index].properties.primaryEndpoints.blob
  secondary: storageAccounts[index + 1].properties.secondaryEndpoints.blob
}

// nested indexer?
output indexViaReference string = storageAccounts[int(storageAccounts[index].properties.creationTime)].properties.accessTier

// dependency on a resource collection
resource storageAccounts2 'Microsoft.Storage/storageAccounts@2019-06-01' = [for account in accounts: {
  name: '${name}-collection-${account.name}'
  location: account.location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  dependsOn: [
    storageAccounts
  ]
}]

// one-to-one paired dependencies
resource firstSet 'Microsoft.Storage/storageAccounts@2019-06-01' = [for i in range(0, length(accounts)): {
  name: '${name}-set1-${i}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]

resource secondSet 'Microsoft.Storage/storageAccounts@2019-06-01' = [for i in range(0, length(accounts)): {
  name: '${name}-set2-${i}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  dependsOn: [
    firstSet[i]
  ]
}]

// depending on collection and one resource in the collection optimizes the latter part away
resource anotherSingleResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: '${name}single-resource-name'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  dependsOn: [
    secondSet
    secondSet[0]
  ]
}