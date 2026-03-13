$script:ProjectDatabaseCache = @{}

function getProjectDatabaseCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$KeyLock
    )

    $lock = Get-Database -Key $KeyLock

    if([string]::IsNullOrWhiteSpace($lock)){
        "No cache lock found for $KeyLock. Cache will be ignored." | Write-MyDebug -Section "ProjectDatabaseCache"
        return $null
    }

    $cache = $script:ProjectDatabaseCache[$KeyLock]

    if($lock -cne $cache.safeId) {
        "Cache lock mismatch for $KeyLock. Cache safeId [$($cache.SafeId)], lock [$lock]. Cache will be ignored." | Write-MyDebug -Section "ProjectDatabaseCache"
        resetProjectDatabaseCache -KeyLock $KeyLock
        return $null
    }

    "Getting fields cache for $KeyLock with lock [$lock] and cache safeId [$($cache.SafeId)]" | Write-MyDebug -Section "ProjectDatabaseCache"
    return $cache.Database
}

function setProjectDatabaseCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$KeyLock,
        [Parameter(Mandatory,Position = 1)][string]$SafeId,
        [Parameter(Mandatory,Position = 2)][object]$Database
    )

    "Setting project cache for $KeyLock with safeId [$SafeId]" | Write-MyDebug -Section "ProjectDatabaseCache"

    # Save safeId to project-lock
    Save-Database -Database $SafeId -Key $KeyLock

     # Set lock in database to prevent concurrent updates
    $script:ProjectDatabaseCache[$KeyLock] = @{
        Database = $Database
        SafeId = $SafeId
    }
}

function resetProjectDatabaseCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$KeyLock
    )

    "Resetting project cache for $KeyLock" | Write-MyDebug -Section "ProjectDatabase"

    Reset-Database -Key $KeyLock
    
    $script:ProjectDatabaseCache.Remove($KeyLock)
}