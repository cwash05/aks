targetScope='subscription'

@description('The principal to assign the role to')
param principalId string

@description('A GUID used to identify the role assignment')
param roleNameGuid string 

param roleDefinitionId string

resource roleNameGuid_resource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuid
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
