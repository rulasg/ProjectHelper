
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
        [Parameter(Position = 2)] [string]$Title,
        [Parameter(Position = 3)] [string]$FieldName,
        [Parameter(Position = 4)] [string]$Value,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $itemId = Get-ItemId $db $Title

    $actualValue = Get-ItemFieldValue $db $itemId $FieldName

    if($actualValue -eq $Value){
        return
    }

    Save-ItemFieldValue $db $itemId $FieldName $Value

} Export-ModuleMember -Function Edit-ProjectItem

<#
.SYNOPSIS
    Get the saved items from a project
.EXAMPLE
    Get-ProjectItemsSaved -Owner "someOwner" -ProjectNumber 666
#>
function Get-ProjectItemsSaved{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-ProjectDatabase $Owner $ProjectNumber

    return $db.Saved
} Export-ModuleMember -Function Get-ProjectItemsSaved