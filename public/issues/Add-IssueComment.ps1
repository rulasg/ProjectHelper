Set-MyInvokeCommandAlias -Alias AddIssueComment -Command 'Invoke-AddIssueComment -SubjectId {subjectid} -Comment "{comment}"'

# 

function Add-IssueCommentDirect {
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

    if ($item.type -ne 'Issue') {
        throw "ItemId [$ItemId] is not an Issue. Type is [$($item.Type)]"
    }

    $response = Invoke-MyCommand -Command 'AddIssueComment' -Parameters @{
        subjectid = $item.contentId
        comment   = $Comment
    }

    # check if the response is null
    if ($response.errors) {
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $false
    }

    if ($null -eq $response.data.addComment.commentEdge.node.url) {
        "Failed to add comment to issue [$ItemId]" | Write-MyError
        return $false
    }

    return $true

} Export-ModuleMember -Function Add-IssueCommentDirect