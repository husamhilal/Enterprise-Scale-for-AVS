targetScope = 'subscription'

param Prefix string
param Location string
@secure()
param Username string
@secure()
param Password string
param VNetResourceGroup string
param VNetName string
param JumpboxSubnet string
param JumpboxSku string
param OSVersion string
param EnableHighPerformance bool
param BootstrapJumpboxVM bool = false
param BootstrapPath string
param BootstrapCommand string
param BastionSubnet string
param AssignPolicy bool
param PolicyAssignmentName string
param PolicyDefinitionID string


module Subnet 'JumpBox/JumpBoxSubnet.bicep' = {
  name: 'Jumpbox-Subnet'
  scope: resourceGroup(VNetResourceGroup)
  params:{
    VNetName: VNetName
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
  }
}

resource JumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Jumpbox'
  location: Location
}

module AzurePolicyAssignment 'Policy/PolicyAssignment.bicep'= if (AssignPolicy) {
  scope: JumpboxResourceGroup
  name: '${PolicyAssignmentName}-JumpboxVMRG'
  params: {
    policyAssignmentName: '${PolicyAssignmentName}-${Prefix}-JB'
    policyDefinitionID: PolicyDefinitionID
  }
}

module Bastion 'JumpBox/Bastion.bicep' = {
  name: '${deployment().name}-Bastion'
  scope: JumpboxResourceGroup
  params:{
    Prefix: Prefix
    SubnetId: Subnet.outputs.BastionSubnetId
    Location: Location
  }
}

module VM 'JumpBox/JumpBoxVM.bicep' = {
  name: '${deployment().name}-VM'
  scope: JumpboxResourceGroup
  params: {
    Prefix: Prefix
    SubnetId: Subnet.outputs.JumpBoxSubnetId
    Location: Location
    Username: Username
    Password: Password
    VMSize: JumpboxSku
    OSVersion: OSVersion
    EnableHighPerformance: EnableHighPerformance
    BootstrapJumpboxVM: BootstrapJumpboxVM
    BootstrapPath: BootstrapPath
    BootstrapCommand: BootstrapCommand
  }
}

output JumpboxResourceId string = VM.outputs.JumpboxResourceId
output JumpboxSAMIPrincipalId string = VM.outputs.JumpboxSAMIPrincipalId
