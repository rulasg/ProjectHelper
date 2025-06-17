Set-MyInvokeCommandAlias -Alias AddItemToProject -Command 'Invoke-AddItemToProject -ProjectId {projectid} -ContentId {contentid}'
Set-MyInvokeCommandAlias -Alias RemoveItemFromProject -Command 'Invoke-RemoveItemFromProject -ProjectId {projectid} -ItemId {itemid}'

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
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 2)][string]$ItemId,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $item = Get-Item $db $ItemId

    return $item
} Export-ModuleMember -Function Get-ProjectItem

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
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Position = 2)] [string]$ItemId,
        [Parameter(Position = 3)] [string]$FieldName,
        [Parameter(Position = 4)] [string]$Value,
        [Parameter()][switch]$Force
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # get the database
    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Find the actual value of the item. Item+Staged
    $item = Get-Item $db $ItemId
    # $itemStaged = Get-ItemStaged $db $ItemId

    # if the item is not found
    if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return $null}

    # Check if the actual value is the same as the target value and we avoid update
    if( IsAreEqual -Object1:$item.$FieldName -Object2:$Value){
        "The value is the same, no need to stage it" | Write-Verbose
        return
    }

    # save the new value
    Save-ItemFieldValue $db $itemId $FieldName $Value

    # Commit change changes to the database
    Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Database $db

} Export-ModuleMember -Function Edit-ProjectItem

function Add-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Position = 2)][string]$Url
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

} Export-ModuleMember -Function Add-ProjectItem

function Remove-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Position = 2)][string]$ItemId
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project id
    $projectId = Get-ProjectId -Owner $Owner -ProjectNumber $ProjectNumber
    if(-not $projectId){
        "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
        return $null
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

} Export-ModuleMember -Function Remove-ProjectItem

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