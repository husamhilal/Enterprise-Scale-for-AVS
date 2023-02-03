param Prefix string
param SubnetId string
param Location string
param Username string
@secure()
param Password string
param VMSize string
param OSVersion string
param EnableHighPerformance bool
param BootstrapJumpboxVM bool
param BootstrapPath string = ''
param BootstrapCommand string = ''

var Name = '${Prefix}-jumpbox'
var Hostname = 'avsjumpbox'

resource Nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: Name
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: SubnetId
          }
        }
      }
    ]
    enableAcceleratedNetworking: EnableHighPerformance ? true : false
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: Name
  location: Location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: Hostname
      adminUsername: Username
      adminPassword: Password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: EnableHighPerformance ? 'Premium_LRS' : 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: Nic.id
        }
      ]
    }
  }
}

resource Bootstrap 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = if(BootstrapJumpboxVM) {
  name: '${VM.name}/CustomScriptExtension'
  location: Location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        BootstrapPath
      ]
      commandToExecute: BootstrapCommand
    }
  }
}

output JumpboxResourceId string = VM.id
output JumpboxSAMIPrincipalId string = VM.identity.principalId
