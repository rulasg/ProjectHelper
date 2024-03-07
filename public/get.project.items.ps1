

function Get-ProjectItemList{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    return $db.items

} Export-ModuleMember -Function Get-ProjectItemList

function Find-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    return $db.items | Where-Object { $_.Title -eq $Title }

} Export-ModuleMember -Function Find-ProjectItemByTitle

function Search-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    return $db.items | Where-Object { $_.Title -like "*$Title*" }

} Export-ModuleMember -Function Search-ProjectItemByTitle

