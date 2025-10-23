function Invoke-AddSubIssue{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string]$IssueId,
        [Parameter(Mandatory)][string]$SubIssueUrl,
        [Parameter()][string]$ReplaceParent
    )

    $query = Get-GraphQLString "addSubIssue.mutant"

    $variables = @{
        input = @{
           issueId = $IssueId
           subIssueUrl = $SubIssueUrl
           replaceParent = [bool]::Parse($ReplaceParent)
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-AddSubIssue
