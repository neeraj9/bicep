param name string
param accounts array
param index int

// single resource
// resource singleResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
//   name: '${name}single-resource-name'
//   location: resourceGroup().location
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }

// resource collection
resource storageAccounts 'Microsoft.Storage/storageAccounts@2019-06-01' = [for account in accounts: {
  name: '${name}-collection-${account.name}'
  location: account.location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]

// special case property access
output indexedCollectionBlobEndpoint string = storageAccounts[index].properties.primaryEndpoints.blob
output indexedCollectionName string = storageAccounts[index].name
output indexedCollectionId string = storageAccounts[index].id
output indexedCollectionType string = storageAccounts[index].type
output indexedCollectionVersion string = storageAccounts[index].apiVersion

// general case property access
output indexedCollectionIdentity object = storageAccounts[index].identity

// // indexed access of two properties
// output indexedEndpointPair object = {
//   primary: storageAccounts[index].properties.primaryEndpoints.blob
//   secondary: storageAccounts[index].properties.secondaryEndpoints.blob
// }

// // nested indexer?
// output indexViaReference string = storageAccounts[int(storageAccounts[index].properties.creationTime)].properties.accessTier


