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
function Get-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position = 0)][string]$ItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $itemlist = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $item = $itemlist.$ItemId

    # If item not found on cache get it directly
    if($null -eq $item){
        $item = Get-ProjectItemDirect -ItemId $ItemId
    }

    return $item
} Export-ModuleMember -Function Get-ProjectItem


function Find-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 0)][string]$Title,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Match,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if($null -eq $items){ return $null}

    # Find item in the database
    if($Match){
        $found = $items.Values | Where-Object { $_.Title -eq $Title }
    } else {
        $found = $items.Values | Where-Object { $_.Title -like "$Title" }
    }

    $ret = $found | ForEach-Object { 
        [PSCustomObject]$_
    } 

    return $ret
} Export-ModuleMember -Function Find-ProjectItem

function Search-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)] [string]$Filter,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}
    
    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if($null -eq $items){ return $null}

    $found = $items.Values | Where-Object { Test-ProjectItemIsLikeAnyField -Item $_ -Value $Filter }

    $ret = @($found | ForEach-Object { 
        [PSCustomObject]$_
    })

    return $ret

} Export-ModuleMember -Function Search-ProjectItem

<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function Edit-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value,
        [Parameter()][switch]$Force
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Force cache update
    # Full sync if force. Skip items if not force
    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

    # Find the actual value of the item. Item+Staged
    $item = Get-Item $db $ItemId
    # $itemStaged = Get-ItemStaged $db $ItemId

    # if the item is not found
    # if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return $null}

    # Check if item exists in cache and if so if the value is the same as the target value and we avoid update
    if($item){
        if( IsAreEqual -Object1:$item.$FieldName -Object2:$Value){
            "The value is the same, no need to stage it" | Write-Verbose
            return
        }
    } else {
        "Staging - Item [$ItemId] not found in project [$Owner/$ProjectNumber] " | Write-Verbose
    }

    # save the new value
    Save-ItemFieldValue $db $itemId $FieldName $Value

    # Commit changes to the database
    Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Database $db

} Export-ModuleMember -Function Edit-ProjectItem

function Add-ProjectItemDirect{
    [CmdletBinding()]
    [alias("Add-ProjectItem")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(ValueFromPipeline,Position = 0)][string]$Url
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project id
    $projectId = Get-ProjectId -Owner $Owner -ProjectNumber $ProjectNumber
    if(-not $projectId){
        "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
        return $null
    }

    # Get item id
    $contentId = Get-ContentIdFromUrl -Url $Url
    if(-not $contentId){
        "Content ID not found for URL [$Url]" | Write-MyError
        return $null
    }

    # Add item to project
    $response = Invoke-MyCommand -Command AddItemToProject -Parameters @{ projectid = $projectId ; contentid = $contentId }

    # check if the response is null
    if($response.errors){
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if($response.data.addProjectV2ItemById.item.id)
    {
        return $response.data.addProjectV2ItemById.item.id
    } else {
        "Item not added to project" | Write-MyError
        return $null
    }

} Export-ModuleMember -Function Add-ProjectItemDirect -Alias Add-ProjectItem

function Remove-ProjectItemDirect{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId
    )

    begin{
        ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}
        
        # Get project id
        $projectId = Get-ProjectId -Owner $Owner -ProjectNumber $ProjectNumber
        if(-not $projectId){
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
        }
    }

    process{

        if (-not $projectId){
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return
        }

        # Remove item from project
        $response = Invoke-MyCommand -Command RemoveItemFromProject -Parameters @{ projectid = $projectId ; itemid = $ItemId }
        
        # check if the response is null
        if($response.errors){
            "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
            return $null
        }
        
        if($response.data.deleteProjectV2Item.deletedItemId -ne $ItemId){
            "Some issue removing [$ItemId]from project" | Write-MyError
            return $null
        }
        
        return $response.data.deleteProjectV2Item.deletedItemId
    }

} Export-ModuleMember -Function Remove-ProjectItemDirect

function Get-ProjectItemDirect{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position = 0)][string]$ItemId
    )

    $response = Invoke-MyCommand -Command GetItem -Parameters @{
        itemid = $ItemId
    }

    # check if the response is null
    if($response.errors){
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if($response.data.node.id -ne $ItemId){
        "Item [$ItemId] not found" | Write-MyError
        return $null
    }

    $item = $response.data.node | Convert-NodeItemToHash

    # Cache item

    return $item
} Export-ModuleMember -Function Get-ProjectItemDirect

function Show-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(ValueFromPipeline)][object]$Item,
        [Parameter()][string[]]$AdditionalFields
    )

    begin{
        $fields = Get-EnvironmentDisplayFields -Fields $AdditionalFields
    } 

    process{
        $ret = $item | Select-Object -Property $Fields

        return $ret
    }
} Export-ModuleMember -Function Show-ProjectItem


function Test-ProjectItemIsLikeAnyField{
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory,Position = 0)][string]$Value
    )
    foreach($key in $item.Keys){
        if($item.$key -Like "*$Value*"){
            return $true
        }
    }

    return $false

}


function IsAreEqual{
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