targetScope = 'subscription'

param Prefix string
param PrimaryLocation string
param AlertEmails array
param PrimaryPrivateCloudName string
param PrimaryPrivateCloudResourceId string
param JumpboxResourceId string
param VNetResourceId string
param ExRConnectionResourceId string
param AssignPolicy bool
param PolicyAssignmentName string
param PolicyDefinitionID string

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Operational'
  location: PrimaryLocation
}

module AzurePolicyAssignment 'Policy/PolicyAssignment.bicep'= if (AssignPolicy) {
  scope: OperationalResourceGroup
  name: '${PolicyAssignmentName}-MonitoringRG'
  params: {
    policyAssignmentName: '${PolicyAssignmentName}-${Prefix}-MON'
    policyDefinitionID: PolicyDefinitionID
  }
}

module ActionGroup 'Monitoring/ActionGroup.bicep' = {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ActionGroup'
  params: {
    Prefix: Prefix
    ActionGroupEmails: AlertEmails
  }
}

module PrimaryMetricAlerts 'Monitoring/MetricAlerts.bicep' = {
  scope: OperationalResourceGroup
  name: '${deployment().name}-MetricAlerts'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrimaryPrivateCloudName
    PrivateCloudResourceId: PrimaryPrivateCloudResourceId
  }
}

module ServiceHealth 'Monitoring/ServiceHealth.bicep' = {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ServiceHealth'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrimaryPrivateCloudName
    PrivateCloudResourceId: PrimaryPrivateCloudResourceId
  }
}

module Dashboard 'Monitoring/Dashboard.bicep' = {
  scope: OperationalResourceGroup
  name: '${deployment().name}-Dashboard'
  params:{
    Prefix: Prefix
    Location: PrimaryLocation
    PrivateCloudResourceId: PrimaryPrivateCloudResourceId
    JumpboxResourceId: JumpboxResourceId
    ExRConnectionResourceId: ExRConnectionResourceId
    VNetResourceId: VNetResourceId
  }
}
