Set-MyInvokeCommandAlias -Alias AddBlockedBy -Command 'Invoke-AddBlockedBy -IssueId {issueid} -BlockingIssueId {blockingissueid}'

<#
.SYNOPSIS
    Mark a project item as blocked by another project item.
.DESCRIPTION
    Both items must be backed by GitHub issues in the selected project.
    ItemId is the blocked item; BlockingItemId identifies its blocker.
    Returns true when the relationship is created, or null on failure.
.EXAMPLE
    Add-ProjectItemBlocked -ItemId PVTI_blocked -BlockingItemId PVTI_blocker -Owner octodemo -ProjectNumber 700
.LINK
    https://docs.github.com/en/graphql/reference/issues#addblockedby---mutation
#>
function Add-ProjectItemBlocked {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$ItemId,
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][string]$BlockingItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    begin {
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber
    }

    process {
        $item = Get-ProjectItem -ItemId $ItemId -Owner $Owner -ProjectNumber $ProjectNumber
        if (!$item) {
            "ItemId [$ItemId] not found on project $Owner/$ProjectNumber" | Write-MyError
            return $null
        }

        $blockingItem = Get-ProjectItem -ItemId $BlockingItemId -Owner $Owner -ProjectNumber $ProjectNumber
        if (!$blockingItem) {
            "BlockingItemId [$BlockingItemId] not found on project $Owner/$ProjectNumber" | Write-MyError
            return $null
        }

        foreach ($issueItem in @($item, $blockingItem)) {
            if ($issueItem.type -ne "Issue" -or [string]::IsNullOrWhiteSpace($issueItem.contentId)) {
                "ItemId [$($issueItem.id)] must be a GitHub Issue. Type is [$($issueItem.type)]" | Write-MyError
                return $null
            }
        }

        if ($item.contentId -ceq $blockingItem.contentId) {
            "ItemId [$ItemId] cannot be blocked by itself" | Write-MyError
            return $null
        }

        $parameters = @{
            issueid = $item.contentId
            blockingissueid = $blockingItem.contentId
        }

        try {
            $response = Invoke-MyCommand -Command AddBlockedBy -Parameters $parameters
        } catch {
            "Failed to block ItemId [$ItemId] by BlockingItemId [$BlockingItemId] - $($_.Exception.Message)" | Write-MyError
            return $null
        }

        if ($response.errors) {
            "Failed to block ItemId [$ItemId] by BlockingItemId [$BlockingItemId] - $($response.errors.message -join '; ')" | Write-MyError
            return $null
        }

        if ($response.data.addBlockedBy.issue.id -cne $item.contentId -or
            $response.data.addBlockedBy.blockingIssue.id -cne $blockingItem.contentId) {
            "Failed to block ItemId [$ItemId] by BlockingItemId [$BlockingItemId]: unexpected mutation response" | Write-MyError
            return $null
        }

        return $true
    }
} Export-ModuleMember -Function Add-ProjectItemBlocked
