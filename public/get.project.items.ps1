

function Get-ProjectItemList{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # if $db is null it rill return null
    return $db.items

} Export-ModuleMember -Function Get-ProjectItemList

function Reset-ProjectItemList{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $saved = Test-ProjectDatabaseSaved -Owner $Owner -ProjectNumber $ProjectNumber

    if($saved -and -Not $Force){
        "There are unsaved changes, please commit or use -Force" | Write-MyError
        return
    }

    Reset-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

} Export-ModuleMember -Function Reset-ProjectItemList

function Find-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $db){ return }

    $ret =  $db.items | Where-Object { $_.Title.Trim().ToLower() -eq $($Title.Trim().ToLower()) }

    return $ret

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

    # return if #db is null
    if($null -eq $db){ return }
    
    $ret = $db.items | Where-Object { $_.Title -like "*$Title*" }
    
    return $ret

} Export-ModuleMember -Function Search-ProjectItemByTitle

