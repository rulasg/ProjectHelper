# Database driver to store and cacche project content and schema

$databaseRoot = "~/.helpers/projecthelper/databaseV2"

function Initialize-DatabaseRoot{
    [CmdletBinding()]
    param()
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Initialize-DatabaseRoot

function Get-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $path =  GetDatabaseFile -Owner $Owner -ProjectNumber $ProjectNumber
    
    if(-Not (Test-Path $path)){
        return $null
    }

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Reset-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )
    $path =  GetDatabaseFile -Owner $Owner -ProjectNumber $ProjectNumber
    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 2)][Object]$Database
    )

    $owner = $Database.owner
    $projectnumber = $Database.number

    $path =  GetDatabaseFile -Owner $owner -ProjectNumber $projectnumber

    $Database | ConvertTo-Json -Depth 10 | Set-Content $path
}

function GetDatabaseFile{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $path = $databaseRoot | Join-Path -ChildPath "$($owner)_$($projectnumber).json"

    return $path
}