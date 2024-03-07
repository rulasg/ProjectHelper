
<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 666 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 666 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function Edit-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter(Position = 2)] [string]$ItemId,
        [Parameter(Position = 3)] [string]$FieldName,
        [Parameter(Position = 4)] [string]$Value,
        [Parameter()][switch]$Force
    )

    # get the database
    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Find the item by title
    $item = Get-Item $db $ItemId

    # check if the value is the same
    if($item.$FieldName -eq $Value){
        return
    }

    # save the new value
    Save-ItemFieldValue $db $itemId $FieldName $Value

} Export-ModuleMember -Function Edit-ProjectItem

<#
.SYNOPSIS
    Get the saved items from a project
.EXAMPLE
    Get-ProjectItemSaved -Owner "someOwner" -ProjectNumber 666
#>
function Get-ProjectItemSaved{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-ProjectDatabase $Owner $ProjectNumber

    return $db.Saved
} Export-ModuleMember -Function Get-ProjectItemSaved