function Invoke-GetNode {
    param(
        [Parameter(Mandatory=$true)][string]$id
    )

    $query = Get-GraphQLString "node.query"

    $variables = @{
        itemId = $id
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-GetNode