
$RECENT_QUERY = "updated:>={date}"

function Update-ProjectRecent{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    # Get Last update date
    $query = Get-UpdateRecentQuery -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Query $Query

    if($ret){
        Set-EnvProjectLastUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }

    return $ret
} Export-ModuleMember -Function Update-ProjectRecent

function Get-UpdateRecentQuery{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    $last = Get-EnvProjectLastUpdate -Owner $Owner -ProjectNumber $ProjectNumber

    # If no last update return no filter to update all
    if ($null -eq $last){
        return ""
    }

    $ret = $RECENT_QUERY -replace "{date}", $last

    "Updated recent query [ $ret ]" | Write-MyDebug -Section "Update-Project"

    return $ret
} Export-ModuleMember -Function Get-UpdateRecentQuery

function Get-EnvProjectLastUpdate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $key = "db-$($Owner)-$($ProjectNumber)-project-LastUpdate"

    $last = Get-EnvItem -Name $key

    "Get last recent update for $Owner/$ProjectNumber with $last" | Write-MyDebug -Section "Update-Project"

    return $last
}

function Set-EnvProjectLastUpdate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber,
        [Parameter(Mandatory)][string]$Value
    )

    $key = "db-$($Owner)-$($ProjectNumber)-project-LastUpdate"

    Set-EnvItem -Name $key -Value $Value

    "Set last recent update for $Owner/$ProjectNumber to $Value" | Write-MyDebug -Section "Update-Project"

}

function Set-EnvProjectLastUpdate_Today{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $now = Get-DateToday

    Set-EnvProjectLastUpdate -Owner $Owner -ProjectNumber $ProjectNumber -Value $now

}