function Invoke-OrgProjectItemByUrl{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$url
    )

    $query = Get-GraphQLString "orgprojectitembyurl.query"

    $variables = @{
        login = $Owner
        number = $ProjectNumber
        url = $Url
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-AddSubIssue
