

Set-MyInvokeCommandAlias -Alias GetIssueOrPullRequest -Command 'Invoke-GetIssueOrPullRequest -Url {url}'


function Get-ContentIdFromUrlDirect{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Url
    )

    $issue = Get-ProjectIssue -Url $url

    $ret = $issue.id

    return $ret
} Export-ModuleMember -Function Get-ContentIdFromUrlDirect