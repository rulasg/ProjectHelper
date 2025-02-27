

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = $null -ne $db

    return $ret 
}

function Test-ProjectDatabaseStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    if($null -eq $db){
        return $false
    }

    if($null -eq $db.Staged){
        return $false
    }

    if($db.Staged.Count -eq 0){
        return $false
    }

    return $true
}

function Get-ProjectDatabase{
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

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    return $db
}

function Reset-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    Reset-Database -Owner $Owner -ProjectNumber $ProjectNumber
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
    
    Save-Database -Database $db
}

function Save-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][hashtable]$Database
    )

    Save-Database -Database $Database
}
