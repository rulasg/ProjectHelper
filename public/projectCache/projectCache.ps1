function Reset-ProjectCache{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { 
        throw "Owner and ProjectNumber are required on Get-Project"
    }


    $staged = Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber
    if(-not (Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        throw "Project $Owner/$ProjectNumber is not staged in the database"
    }

    Reset-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
} Export-ModuleMember -Function Reset-ProjectCache

function Get-ProjectCacheFile{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
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