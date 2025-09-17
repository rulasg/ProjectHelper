function Resolve-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Database,
        [Parameter(Mandatory, Position = 1)][string]$ItemId,
        [Parameter()][switch]$Force
    )

    $dirty = $false

    # Get Item to know what we are updating
    $item = Get-Item -Database $Database -ItemId $ItemId

    if (( ! $item ) -or $Force) {
        "Fetching item [$ItemId] from API" | Write-Verbose
        
        # Get direct. No cache as we are in a database modification context
        $item = Get-ProjectItemDirect -ItemId $ItemId

        if ( ! $item ) {
            "Item [$ItemId] not found in API" | Write-MyError
            return $null, $false
        }

        # Add to database
        Set-Item $Database $item

        # Get item again to allow the merge between staged and project fields
        $item = Get-Item $Database $itemId

        $dirty = $true
    }

    return $item, $dirty

}