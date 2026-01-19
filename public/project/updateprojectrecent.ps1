
$RECENT_QUERY = "updated:>={date}"

function Update-ProjectRecent{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Update-Project"
    }

    # Get Last update date
    $query = Get-UpdateRecentQuery -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = Update-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query

    if($ret){
        Set-EnvItem_Last_RecentUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }

    return $ret
} Export-ModuleMember -Function Update-ProjectRecent

function Get-UpdateRecentQuery{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    $last = Get-EnvItem_Last_RecentUpdate -Owner $Owner -ProjectNumber $ProjectNumber

    # If no last update return no filter to update all
    if ($null -eq $last){
        return ""
    }

    $ret = $RECENT_QUERY -replace "{date}", $last

    return $ret
} Export-ModuleMember -Function Get-UpdateRecentQuery

function Get-EnvItem_Last_RecentUpdate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $last = Get-EnvItem -Name "EnvironmentCache_Last_RecentUpdate_$($Owner)_$($ProjectNumber)"

    Write-MyDebug "EnvItem_Last_RecentUpdate" "Last recent update for $Owner/$ProjectNumber is $last"

    return $last
}

function Set-EnvItem_Last_RecentUpdate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber,
        [Parameter(Mandatory)][string]$Value
    )

    Set-EnvItem -Name "EnvironmentCache_Last_RecentUpdate_$($Owner)_$($ProjectNumber)" -Value $Value

    Write-MyDebug "EnvItem_Last_RecentUpdate" "Set last recent update for $Owner/$ProjectNumber to $Value"

}

function Set-EnvItem_Last_RecentUpdate_Today{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $now = Get-DateToday

    Set-EnvItem_Last_RecentUpdate -Owner $Owner -ProjectNumber $ProjectNumber -Value $now

}