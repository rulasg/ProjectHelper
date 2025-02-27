
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

    $db = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

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
    $db = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Find the item by title
    $item = Get-Item $db $ItemId

    # if the item is not found
    if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return $null}

    # check if the value is the same
    if($item.$FieldName -eq $Value){
        return
    }

    # save the new value
    Save-ItemFieldValue $db $itemId $FieldName $Value

    # Commit change changes to the database
    Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Database $db

} Export-ModuleMember -Function Edit-ProjectItem
