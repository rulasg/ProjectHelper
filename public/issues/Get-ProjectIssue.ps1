
Set-MyInvokeCommandAlias -Alias GetIssueOrPullRequest -Command 'Invoke-GetIssueOrPullRequest -Url {url}'

function Get-ProjectIssue {
    [CmdletBinding()]
    param (
        # url
        [Parameter(Mandatory,Position=0)][string]$Url
    )

    $params = @{
        url = $Url
    }
    
    $response = Invoke-MyCommand -Command GetIssueOrPullRequest -Parameters $params

    $resource = $response.data.resource

    return $resource

} Export-ModuleMember -Function Get-ProjectIssue