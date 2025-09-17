

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $prj = Get-Database -Key $key

    $ret = $null -ne $prj

    return $ret
}

function Test-ProjectDatabaseStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $prj = Get-Database -Key $key

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

    $key = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $prj = Get-Database -Key $key

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

    $dbKey = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    Reset-Database -Key $dbKey
}

function Save-ProjectV2toDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2,
        [Parameter(Position = 1)][Object[]]$Items,
        [Parameter(Position = 2)][Object[]]$Fields
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

    $db.items = $items
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
    
    $dbkey = Get-DatabaseKey -Owner $owner -ProjectNumber $projectnumber

    if($Safe){
        $oldDatabase = Get-Database -Key $dbkey

        if ($oldDatabase.safeId -ne $Database.safeId){
            throw "The database has changed since it was read. Aborting save to prevent overwriting changes."
        }

    }

    # Add safe mark
    $Database.safeId = [guid]::NewGuid().ToString()

    Save-Database -Key $dbkey -Database $Database
}

function Get-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $ret = "$($owner)_$($projectnumber)"

    return $ret
}