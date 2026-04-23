function Resolve-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Database,
        [Parameter()][string]$ItemId,
        [Parameter()][string]$Url,
        [Parameter()][switch]$Force
    )

    # $item and $url can not be both empty
    if([string]::IsNullOrWhiteSpace($ItemId) -and [string]::IsNullOrWhiteSpace($Url)){
        "Either ItemId or Url must be provided" | Write-MyError
        return $null, $false
    }

    $dirty = $false

    # When no url use ItemID
    if([string]::IsNullOrWhiteSpace($Url)){
        $item = Get-Item -Database $Database -ItemId $ItemId
    } else{
        $item = Get-ItemByUrl -Database $Database -Url $Url
        $ItemId = $item.id
    }

    if ($Force -or -not $item) {
        "Fetching item [$ItemId] from API" | Write-Verbose

        # Get direct. No cache as we are in a database modification context
        $item = Get-ProjectItemDirect -ItemId $ItemId

        if ( ! $item ) {
            "Item [$ItemId] not found in API" | Write-MyError
            return $null, $false
        }

        # Add Sanity check for item
        # Ensure that we hare retrieved an item for the correct database
        # As Get-ProjectItemDirect retrives a node based on item we do not know 
        # if this itemid belongs to this project or not until here.
        #
        # Find bugs early when calling to resolve ItemId of wrong projects.
        if($Database.ProjectId -ne $Item.projectId){
            Wait-Debugger
        }

        # Add to database
        Set-Item $Database $item

        # Get item again to allow the merge between staged and project fields
        $item = Get-Item $Database $itemId

        $dirty = $true
    }

    return $item, $dirty

}