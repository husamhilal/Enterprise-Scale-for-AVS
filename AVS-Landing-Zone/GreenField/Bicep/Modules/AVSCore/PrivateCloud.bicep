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
  }
}

resource PrivateCloudWithInternet 'Microsoft.AVS/privateClouds@2021-12-01' = if(EnableInternet) {
  name: PrivateCloud.name
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
    internet: 'Enabled'
  }
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
