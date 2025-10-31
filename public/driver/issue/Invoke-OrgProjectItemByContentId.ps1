function Invoke-OrgProjectItemByContentId{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$ContentId
    )

    $query = Get-GraphQLString "orgprojectitembycontentid.query"

    $variables = @{
        login = $Owner
        number = $ProjectNumber
        contentid = $ContentId
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-AddSubIssue
