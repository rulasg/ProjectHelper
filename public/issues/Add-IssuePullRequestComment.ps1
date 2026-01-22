
function Add-IssuePullRequestCommentDirect {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId,
        [Parameter(Mandatory, Position = 1)][string]$Comment
    )

    # Try to find item on context project
    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if (! [string]::IsNullOrWhiteSpace($owner) -and ! [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        $item = Get-ProjectItem -ItemId $ItemId -Owner $Owner -ProjectNumber $ProjectNumber
    }

    # If not found get the item directly
    if (-not $item) {
        $item = Get-ProjectItemDirect -ItemId $ItemId
    }

    if (-not $item) {
        throw "ItemId [$ItemId] not found"
    }

    if ( ! ($item.type -in ('Issue', 'PullRequest')) ) {
        "ItemId [$ItemId] is not an Issue. Type is [$($item.type)]" | Write-Error
        return $null
    }

    $response = Invoke-MyCommand -Command 'AddComment' -Parameters @{
        subjectid = $item.contentId
        comment   = $Comment
    }

    # check if the response is null
    if ($response.errors) {
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    $url = $response.data.addComment.commentEdge.node.url

    if ($null -eq $url) {
        "Failed to add comment to issue [$ItemId]" | Write-MyError
        return $null
    }

    return $url

} Export-ModuleMember -Function Add-IssuePullRequestCommentDirect