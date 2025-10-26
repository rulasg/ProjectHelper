function Invoke-RemoveIssue {
    param(
        [Parameter(Mandatory = $true)][string]$IssueId
    )

    $query = Get-GraphQLString "removeIssue.mutant"

    $variables = @{
        input = @{
            issueId = $IssueId
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-RemoveIssue