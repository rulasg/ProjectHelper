function Invoke-UpdateProjectV2Collaborators{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProjectId,
        [Parameter(Mandatory=$true)][array]$collaborators
    )

    $query = Get-GraphQLString "updateProjectV2Collaborators.mutant"

    $variables = @{
        input = @{
           projectId = $ProjectId
           collaborators = $collaborators
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response

} Export-ModuleMember -Function Invoke-UpdateProjectV2Collaborators