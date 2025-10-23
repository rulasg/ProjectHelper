
function Get-ProjectIssue {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Url
    )

    # Check the cache of the default project

    $owner,$projectNumber = Get-OwnerAndProjectNumber

    $cache = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName "url" -Filter $Url -Exact

    if( $cache ) {
        return $cache
    }

    $issue = Get-ProjectIssueDirect -Url $Url

    return $issue
} Export-ModuleMember -Function Get-ProjectIssue