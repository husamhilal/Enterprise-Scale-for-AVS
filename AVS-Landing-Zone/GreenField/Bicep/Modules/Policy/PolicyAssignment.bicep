param policyAssignmentName string
param policyDefinitionID string

resource Assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
    name: policyAssignmentName
    properties: {
        policyDefinitionId: policyDefinitionID
    }
}

output assignmentId string = Assignment.id
