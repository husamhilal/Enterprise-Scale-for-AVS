targetScope = 'subscription'

param Location string
param Prefix string
param PrivateCloudAddressSpace string
param PrivateCloudSKU string
param PrivateCloudHostCount int
param EnableInternet bool
param PolicyAssignmentName string
param PolicyDefinitionID string

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-PrivateCloud'
  location: Location
}

module AzurePolicyAssignment 'Policy/PolicyAssignment.bicep'= {
  scope: PrivateCloudResourceGroup
  name: '${PolicyAssignmentName}-AVSRG'
  params: {
    policyAssignmentName: PolicyAssignmentName
    policyDefinitionID: PolicyDefinitionID
  }
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-PrivateCloud'
  params: {
    Prefix: Prefix
    Location: Location
    NetworkBlock: PrivateCloudAddressSpace
    SKUName: PrivateCloudSKU
    ManagementClusterSize: PrivateCloudHostCount
    EnableInternet: EnableInternet
  }
}

output PrivateCloudName string = PrivateCloud.outputs.PrivateCloudName
output PrivateCloudResourceGroupName string = PrivateCloudResourceGroup.name
output PrivateCloudResourceId string = PrivateCloud.outputs.PrivateCloudResourceId
