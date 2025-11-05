
Set-MyInvokeCommandAlias -Alias GetIssueOrPullRequest -Command 'Invoke-GetIssueOrPullRequest -Url {url}'

function Get-ProjectIssueDirect {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Url
    )

    # Check the project cache of the default project
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

} Export-ModuleMember -Function Get-ProjectIssueDirect

function Get-ProjectIssue {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Url,
        [Parameter()][switch]$Force
    )

    # Check the project cache of the default project
    $owner,$projectNumber = Get-OwnerAndProjectNumber
    $item = Get-ProjectItemByUrl -Owner $owner -ProjectNumber $projectNumber -Url $Url -PassThru -Force:$Force
    if( $item ) { 
        $issue = $item | Convert-ItemToIssue
        return $issue
    }

    # Not in cache. Get Direct
    $issue = Get-ProjectIssueDirect -Url $Url

    # TODO: update the cache if issue is an item of the project
    # This will required or transform Issue to Item or create a new issue database

    return $issue   

} Export-ModuleMember -Function Get-ProjectIssue

function Convert-ItemToIssue {
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$Item
    )

    process {

        $issue = @{
            __typename = "Issue"
            id         = $Item.contentId
            title      = $Item.Title
            body       = $Item.Body
            number     = $Item.number
            url        = $Item.urlContent
            repository = $Item.Repository
        }
        return $issue
    }

}