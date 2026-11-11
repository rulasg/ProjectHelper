<#
.DESCRIPTION
    Integration function not intended for direct user use.
#>
function Invoke-AddBlockedBy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$IssueId,
        [Parameter(Mandatory)][string]$BlockingIssueId
    )

    $query = Get-GraphQLString "addBlockedBy.mutant"
    $variables = @{
        input = @{
            issueId = $IssueId
            blockingIssueId = $BlockingIssueId
        }
    }

    return Invoke-GraphQL -Query $query -Variables $variables
} Export-ModuleMember -Function Invoke-AddBlockedBy
