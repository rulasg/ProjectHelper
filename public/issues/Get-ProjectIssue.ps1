
function Get-ProjectIssue {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Url
    )

    # Check the project cache of the default project
    $owner,$projectNumber = Get-OwnerAndProjectNumber
    $cache = Get-ProjectItemByUrl -Owner $owner -ProjectNumber $projectNumber -Url $Url
    if( $cache ) { return $cache }

    # Find project
    $params = @{
        url = $Url
    }

    $response = Invoke-MyCommand -Command GetIssueOrPullRequest -Parameters $params

    if($response.data.resource){
        $ret = $response.data.resource
    } else {
        "Resource not found for URL [$Url]" | Write-MyError
        $ret = $null
    }

    # TODO: update the cache if issue is an item of the project
    # This will required or transform Issue to Item or create a new issue database

    return $ret

} Export-ModuleMember -Function Get-ProjectIssue