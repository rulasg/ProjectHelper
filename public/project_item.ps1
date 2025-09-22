Set-MyInvokeCommandAlias -Alias AddItemToProject -Command 'Invoke-AddItemToProject -ProjectId {projectid} -ContentId {contentid}'
Set-MyInvokeCommandAlias -Alias RemoveItemFromProject -Command 'Invoke-RemoveItemFromProject -ProjectId {projectid} -ItemId {itemid}'
Set-MyInvokeCommandAlias -Alias GetItem -Command 'Invoke-GetItem -ItemId {itemid}'

<#
.SYNOPSIS
    Get a project item.
.DESCRIPTION
    Fields will show th emerge between Project and Staged Item fields values
.EXAMPLE
    Get-ProjectItem -Owner "someOwner" -ProjectNumber 164 -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc
#>
function Get-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
    
        # Get Item from Project database
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

        if(! $db){ "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError; return $null}

        # Durty flag
        $durty = $false
    }

    process {
        $item, $dirty = Resolve-ProjectItem -Database $db -ItemId $ItemId -Force:$Force

        return $item
    }
    
    end {
        if ($dirty) {
            "Saving dirty database" | Write-Verbose
            Save-ProjectDatabaseSafe -Database $db
        }
    }

} Export-ModuleMember -Function Get-ProjectItem

# function Set-ProjectItem {
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory, ValueFromPipeline, Position = 0)][object]$Item,
#         [Parameter()][string]$Owner,
#         [Parameter()][string]$ProjectNumber
#     )
#     ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
#     if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
#
#     $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
#
#     Set-Item $db $item
#
#     Save-ProjectDatabaseSafe -Database $db
# }

function Remove-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    }

    process {
        Remove-Item $db $itemId
    }

    end {
        Save-ProjectDatabaseSafe -Database $db
    }

}

function Find-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, Position = 0)][string]$Title,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Match,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if ($null -eq $items) { return $null }

    # Find item in the database
    if ($Match) {
        $found = $items.Values | Where-Object { $_.Title -eq $Title }
    }
    else {
        $found = $items.Values | Where-Object { $_.Title -like "$Title" }
    }

    $ret = $found | ForEach-Object { 
        [PSCustomObject]$_
    } 

    return $ret
} Export-ModuleMember -Function Find-ProjectItem

function Search-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)] [string]$Filter,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if ($null -eq $items) { return $null }

    $found = $items.Values | Where-Object { Test-ProjectItemIsLikeAnyField -Item $_ -Value $Filter }

    $ret = @($found | ForEach-Object { 
            [PSCustomObject]$_
        })

    return $ret

} Export-ModuleMember -Function Search-ProjectItem

function Get-ProjectItems {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if ($null -eq $items) { return $null }

    $ret = @($items.Values | ForEach-Object { 
            [PSCustomObject]$_
        } )

    return $ret

} Export-ModuleMember -Function Get-ProjectItems

function Open-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [string]$ItemId
    )

    begin {

        "Project set to [$owner/$ProjectNumber]" | Write-Verbose

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
            throw "Owner and ProjectNumber are required on Open-ProjectItem"
        }
    }

    process {

        "Opening item [$ItemId] in project [$Owner/$ProjectNumber]" | Write-Verbose
   
        $item = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $ItemId
        if (-not $item) {
            throw "Item not found for Owner [$Owner], ProjectNumber [$ProjectNumber] and ItemId [$ItemId]"
        }
        
        if (-not $item.url) {
            # We should never reach this point as we are setting url for drafts at Convert-NodeItemToHash
            "No URL found for Item [$ItemId] type $($item.type)" | Write-Error
            return 
        }
        
        Open-Url -Url $item.url
    }
} Export-ModuleMember -Function Open-ProjectItem

<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function Edit-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value,
        [Parameter()][switch]$Force
    )
    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

    # Force cache update
    # Full sync if force. Skip items if not force
    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

    # Find the actual value of the item. Item+Staged
    # $item = Get-ProjectItem -ItemId $ItemId -Owner $Owner -ProjectNumber $ProjectNumber
     ($item, $dirty) = Resolve-ProjectItem -Database $db -ItemId $ItemId

    # if the item is not found
    if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return $null}

    # Check if value is the same
    if ( IsEqual -Object1:$item.$FieldName -Object2:$Value) {
        "The value is the same, no need to stage it" | Write-Verbose
        return
    }

    # save the new value
    Save-ItemFieldValue $db $itemId $FieldName $Value

    # Commit changes to the database
    Save-ProjectDatabaseSafe -Database $db

} Export-ModuleMember -Function Edit-ProjectItem

function Add-ProjectItemDirect {
    [CmdletBinding()]
    [alias("Add-ProjectItem", "api")]
    param(
        [Parameter(ValueFromPipeline, Position = 0)][string]$Url,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$NoCache
    )

    process {

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

        # Get project id
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
        $projectId = $db.ProjectId
        if (-not $projectId) {
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return $null
        }

        # Get item id
        $contentId = Get-ContentIdFromUrl -Url $Url
        if (-not $contentId) {
            "Content ID not found for URL [$Url]" | Write-MyError
            return $null
        }

        # Add item to project
        $response = Invoke-MyCommand -Command AddItemToProject -Parameters @{ projectid = $projectId ; contentid = $contentId }

        # check if the response is null
        if ($response.errors) {
            "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
            return $null
        }

        $item = $response.data.addProjectV2ItemById.item

        if ($item) {
            $ret = $item.id

            if (! $NoCache) {
                "Adding item [$ret] to cache" | Write-Verbose

                $item = $item | Convert-NodeItemToHash

                Set-Item $db $item

                Save-ProjectDatabaseSafe -Database $db

            }

            return $ret

        }
        else {
            "Item not added to project" | Write-MyError
            return $null
        }
    }

} Export-ModuleMember -Function Add-ProjectItemDirect -Alias "Add-ProjectItem", "api"

function Remove-ProjectItemDirect {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId,
        [Parameter()][switch]$NoCache
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
        
        # Get project id
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
        if ($db) {
            $projectId = $db.ProjectId
        }
        else {
            throw "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]"
        }
    }

    process {

        if (-not $projectId) {
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return
        }

        # Remove item from project
        $response = Invoke-MyCommand -Command RemoveItemFromProject -Parameters @{ projectid = $projectId ; itemid = $ItemId }
        
        # check if the response is null
        if ($response.errors) {
            "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
            return $null
        }
        
        if ($response.data.deleteProjectV2Item.deletedItemId -ne $ItemId) {
            "Some issue removing [$ItemId] from project" | Write-MyError
            return $null
        }
        
        $ret = $response.data.deleteProjectV2Item.deletedItemId

        # Remove item from cache
        "Removing item [$ItemId] from cache" | Write-Verbose
        Remove-Item $db $ItemId
        Save-ProjectDatabaseSafe -Database $db

        return $ret
    }

} Export-ModuleMember -Function Remove-ProjectItemDirect

function Get-ProjectItemDirect {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId
    )

    $response = Invoke-MyCommand -Command GetItem -Parameters @{
        itemid = $ItemId
    }

    # check if the response is null
    if ($response.errors) {
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if ($response.data.node.id -ne $ItemId) {
        "Item [$ItemId] not found" | Write-MyError
        return $null
    }

    $item = $response.data.node | Convert-NodeItemToHash

    return $item
} Export-ModuleMember -Function Get-ProjectItemDirect

function Show-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(ValueFromPipeline)][object]$Item,
        [Parameter()][string[]]$AdditionalFields
    )

    begin {
        $fields = Get-EnvironmentDisplayFields -Fields $AdditionalFields

        $fields | Write-Verbose
    } 

    process {
        $ret = $item | Select-Object -Property $Fields

        return $ret
    }
} Export-ModuleMember -Function Show-ProjectItem


function Test-ProjectItemIsLikeAnyField {
    param(
        [Parameter(Mandatory, ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory, Position = 0)][string]$Value
    )
    foreach ($key in $item.Keys) {
        if ($item.$key -Like "*$Value*") {
            return $true
        }
    }

    return $false

}


function IsEqual {
    param(
        [object]$Object1,
        [object]$Object2
    )

    $Object1 = [string]::IsNullOrEmpty($Object1) ? $null : $Object1
    $Object2 = [string]::IsNullOrEmpty($Object2) ? $null : $Object2

    # Check if the objects are equal
    $ret = $Object1 -eq $Object2

    return $ret
}