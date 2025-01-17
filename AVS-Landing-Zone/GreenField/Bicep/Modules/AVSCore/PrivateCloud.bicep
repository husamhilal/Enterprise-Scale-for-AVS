param Prefix string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string
param EnableInternet bool

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' = {
  name: '${Prefix}-SDDC'
  sku: {
    name: SKUName
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
    internet: EnableInternet ? 'Enabled' : 'Disabled'
  }
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
