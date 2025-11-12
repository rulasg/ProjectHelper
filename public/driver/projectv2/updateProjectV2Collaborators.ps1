function Invoke-UpdateProjectV2Collaborators{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProjectId,
        [Parameter(Mandatory=$true)][ValidateSet("READER","WRITER","NONE","ADMIN")]
        [string]$Role,
        [Parameter(Mandatory=$true)][string] $CollaboratorsIds
    )

    $list = $CollaboratorsIds.Split(@(" "),[System.StringSplitOptions]::RemoveEmptyEntries)

    $array = $list | ForEach-Object {
        @{
            userId = $_
            role   = $Role
        }
    }

    $query = Get-GraphQLString "updateProjectV2Collaborators.mutant"

    $variables = @{
        input = @{
           projectId = $ProjectId
           collaborators = $array
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response

} Export-ModuleMember -Function Invoke-UpdateProjectV2Collaborators