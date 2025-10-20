function Invoke-Repository {
    param(
        [Parameter(Mandatory=$true)][string]$Owner,
        [Parameter(Mandatory=$true)][string]$Name
    )

    $query = Get-GraphQLString "repository.query"

    $variables = @{
        owner = $Owner
        name  = $Name
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-Repository