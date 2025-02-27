

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $key = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
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

    $key = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
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
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    if($force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)){
        $result = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        if( ! $result){ return }
    }

    $key = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $prj = Get-Database -Key $key

    return $prj
}

function Reset-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $dbKey = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    Reset-Database -Key $dbKey
}

function Set-ProjectDatabaseV2{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2,
        [Parameter(Position = 1)][Object[]]$Items,
        [Parameter(Position = 2)][Object[]]$Fields
    )

    $owner = $ProjectV2.owner.login
    $projectnumber = $ProjectV2.number

    $dbkey = GetDatabaseKey -Owner $owner -ProjectNumber $projectnumber

    $db = @{}
    
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
    
    Save-Database -Key $dbkey -Database $db
}

function Save-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter(Position = 0)][hashtable]$Database
    )

    $dbkey = GetDatabaseKey -Owner $owner -ProjectNumber $projectnumber
    Save-Database -Key $dbkey -Database $Database
}

function GetDatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $ret = "$($owner)_$($projectnumber)"

    return $ret
}