

function Get-ProjectItems{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    return $db.items

} Export-ModuleMember -Function Get-ProjectItems
