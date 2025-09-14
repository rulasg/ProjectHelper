function Remove-ProjectCache{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Get-Project"
    }

    if(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber){
        throw "Project $Owner/$ProjectNumber has pending changes. Please commit changes with Sync-ProjectItemStaged or discard them with Reset-ProjectItemStaged before resetting the ProjectCache."
    }

    Reset-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
} Export-ModuleMember -Function Remove-ProjectCache

function Get-ProjectCacheFile{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Get-Project"
    }

    $key = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $path = Get-DatabaseFile -Key $key

    if($path | Test-Path ){
        return $path
    }

    return $null

} Export-ModuleMember -Function Get-ProjectCacheFile