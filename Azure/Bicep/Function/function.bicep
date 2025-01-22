param FunctionAppName string
param ManagedIdentityName string
param VirtualNetworkObject object
param AppServicePlanObject object

resource azureMSI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: ManagedIdentityName
  location: resourceGroup().location
}

var managedIdentityId = azureMSI.id

resource azureFunction 'Microsoft.Web/sites@2024-04-01' = {
  name: FunctionAppName
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }

  properties: {
    virtualNetworkSubnetId: resourceId(VirtualNetworkObject.subId, VirtualNetworkObject.rgName, 'Microsoft.Network/VirtualNetworks/subnets', VirtualNetworkObject.vnetName, VirtualNetworkObject.subnetName)
    serverFarmId: 'ToDo'
    httpsOnly: true
    siteConfig: {
      numberOfWorkers: 1
      alwaysOn: true
      ipSecurityRestrictions: [{name: 'ToDo'}]
      scmIpSecurityRestrictions: [{name: 'ToDo'}]
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsUseMain: false
      appSettings: [
        {
          name: 'Function_Extension_Version'
          value: '~4'
        }
      ]
    }
  }
}
