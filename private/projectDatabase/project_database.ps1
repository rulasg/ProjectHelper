

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key,$keyLock = Get-ProjectDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = Test-Database -Key $key

    return $ret
}

function Test-ProjectDatabaseStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    if($null -eq $prj){
        return $false
    }

    if($null -eq $prj.Staged){
        return $false
    }

    if($prj.Staged.Count -eq 0){
        return $false
    }

    return $true
}

function Get-ProjectFromDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key,$keyLock = Get-ProjectDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    
    $prj = getProjectDatabaseCache -KeyLock $keyLock

    if($null -ne $prj){
        "Project cache hit for $Owner/$ProjectNumber" | Write-MyDebug -Section "ProjectDatabase"
        return $prj
    }
    
    # No cache or cache mismatch, read from database
    $prj = Get-Database -Key $key

    if($null -eq $prj){
        return $null
    }

    $prj.fields = $prj.fields | Copy-MyHashTable
    $prj.items  = $prj.items  | Copy-MyHashTable
    $prj.Staged = $prj.Staged | Copy-MyHashTable

    return $prj
}

function Reset-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $dbKey, $dbKeyLock = Get-ProjectDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    Reset-Database -Key $dbKey
    resetProjectDatabaseCache -Owner $Owner -ProjectNumber $ProjectNumber
}

function Save-ProjectV2toDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2,
        [Parameter(Position = 1)][hashtable]$Items,
        [Parameter(Position = 1)][hashtable]$QueryItems,
        [Parameter(Position = 2)][hashtable]$Fields
    )

    $owner = $ProjectV2.owner.login
    $projectnumber = $ProjectV2.number

    $db = New-Object System.Collections.Hashtable

    $db.url              = $ProjectV2.url
    $db.shortDescription = $ProjectV2.shortDescription
    $db.public           = $ProjectV2.public
    $db.closed           = $ProjectV2.closed
    $db.title            = $ProjectV2.title
    $db.ProjectId        = $ProjectV2.id
    $db.readme           = $ProjectV2.readme

    $db.owner            = $owner
    $db.number           = $projectnumber

    # Full list update
    $db.items = $Items

    # Update just a few items
    if($QueryItems){
        # Update each of the items to avoid replacing all
        foreach ($item in $QueryItems.Values){
            Set-Item $db $item
        }
    }

    # Update fields
    $db.fields = $fields

    # This is the only Save.ProjectDatabase that should not be called with -Safe
    Save-ProjectDatabase -Database $db
}

function Save-ProjectDatabaseSafe{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][hashtable]$Database
    )
    Save-ProjectDatabase -Database $Database -Safe
}

function Save-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][hashtable]$Database,
        [Parameter()][switch]$Safe
    )

    $owner = $Database.owner
    $projectnumber = $Database.number

    if([string]::IsNullOrWhiteSpace($owner)){
        throw "Database.owner is null or empty"
    }
    if($projectnumber -le 0){
        throw "Database.number is null or not a positive integer"
    }

    $dbkey, $dbkeyLock = Get-ProjectDatabaseKey -Owner $owner -ProjectNumber $projectnumber

    if($Safe){
        $oldDatabase = Get-Database -Key $dbkey

        if ($oldDatabase.safeId -ne $Database.safeId){
            throw "The database has changed since it was read. Aborting save to prevent overwriting changes."
        }
    }

    # Add safe mark
    $Database.safeId = [guid]::NewGuid().ToString()

    # Save database
    Save-Database -Key $dbkey -Database $Database
    setProjectDatabaseCache -KeyLock $dbkeyLock -SafeId $Database.safeId -Database $Database
}

function Get-ProjectDatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key = Get-DatabaseKey  $Owner  $ProjectNumber "project"
    $keylock = "$key-lock"

    return $key, $keylock
}

$script:ProjectDatabaseCache = @{}

function getProjectDatabaseCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$KeyLock
    )

    $lock = Get-Database -Key $KeyLock

    if([string]::IsNullOrWhiteSpace($lock)){
        "No cache lock found for $KeyLock. Cache will be ignored." | Write-MyDebug -Section "ProjectDatabase"
        return $null
    }

    $cache = $script:ProjectDatabaseCache[$KeyLock]

    if($lock -cne $cache.safeId) {
        "Cache lock mismatch for $KeyLock. Cache safeId [$($cache.SafeId)], lock [$lock]. Cache will be ignored." | Write-MyDebug -Section "ProjectDatabase"
        resetProjectDatabaseCache -KeyLock $KeyLock
        return $null
    }

    "Getting fields cache for $KeyLock with lock [$lock] and cache safeId [$($cache.SafeId)]" | Write-MyDebug -Section "ProjectDatabase"
    return $cache.Database
}

function setProjectDatabaseCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$KeyLock,
        [Parameter(Mandatory,Position = 1)][string]$SafeId,
        [Parameter(Mandatory,Position = 2)][object]$Database
    )

    "Setting project cache for $KeyLock with safeId [$SafeId]" | Write-MyDebug -Section "ProjectDatabase"

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

    Reset.Database -Key $KeyLock
    
    $script:ProjectDatabaseCache.Remove($KeyLock)
}