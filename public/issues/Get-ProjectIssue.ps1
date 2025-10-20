
Set-MyInvokeCommandAlias -Alias GetIssueOrPullRequest -Command 'Invoke-GetIssueOrPullRequest -Url {url}'

function Get-ProjectIssueDirect {
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

} Export-ModuleMember -Function Get-ProjectIssueDirect

function Get-ProjectIssue {
    param(
        [Parameter(Position = 0)][string]$Url
    )

    # Check the cache of the default project

    $owner,$projectNumber = Get-OwnerAndProjectNumber

    $cache = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -fieldName "url" -fieldValue $Url -ExactMatch

    if( $cache ) {
        return $cache
    }

    $issue = Get-ProjectIssueDirect -Url $Url

    return $issue
} Export-ModuleMember -Function Get-ProjectIssue