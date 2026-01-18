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
    $last = Get-EnvItem_Last_RecentUpdate -Owner $Owner -ProjectNumber $ProjectNumber
    $query = ($null -eq $last) ? $null : "updated:<$last"

    $ret = Update-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query

    if($result){
        Set-EnvItem_Last_RecentUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }

    return $ret
} Export-ModuleMember -Function Update-ProjectRecent

function Set-EnvItem_Last_RecentUpdate_Today{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $now = Get-DateToday
    Set-EnvItem -Name "EnvironmentCache_Last_RecentUpdate_$($Owner)_$($ProjectNumber)" -Value $now

}

function Get-EnvItem_Last_RecentUpdate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][int]$ProjectNumber
    )

    $last = Get-EnvItem -Name "EnvironmentCache_Last_RecentUpdate_$($Owner)_$($ProjectNumber)"

    return $last
}