function Invoke-UpdateProjectV2 {
    param(
        [Parameter()][string]$ProjectId,
        [Parameter()][string]$ReadMeBase64
    )

    $query = Get-GraphQLString "updateProjectV2.mutant"

    $readMe = $ReadMeBase64 | Convertfrom-Base64

    $variables = @{
        input = @{
            projectId    = $ProjectId
            readme       = $readMe
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-UpdateProjectV2