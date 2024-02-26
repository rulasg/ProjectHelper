
function Edit-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter(Position = 3)] [string]$FieldName,
        [Parameter(Position = 4)] [string]$Value,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$Save
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $itemId = Get-ItemId $db $Title

    $actualValue = Get-ItemFieldValue $db $itemId $FieldName

    if($actualValue -eq $Value){
        return
    }

    Save-ItemFieldValue $db $itemId $FieldName $Value

} Export-ModuleMember -Function Edit-ProjectItem

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