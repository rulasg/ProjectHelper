function Invoke-GetItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$ItemId
    )

    $query =  Get-GraphQLString "getProjectV2Item.query"

    # Define the variables for the request
    $variables = @{
        itemId = $ItemId
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-GetItem