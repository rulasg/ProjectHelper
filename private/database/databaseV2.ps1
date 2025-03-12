# Database driver to store the cache

# Invoke to allow mockig the store path on testing
Set-MyInvokeCommandAlias -Alias GetDatabaseStorePath -Command "Invoke-ProjectHelperGetDatabaseStorePath"

$DATABASE_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "databaseCache"

# Create the database root if it does not exist
if(-Not (Test-Path $DATABASE_ROOT)){
    New-Item -Path $DATABASE_ROOT -ItemType Directory
}

function Reset-DatabaseStore{
    [CmdletBinding()]
    param()

        $databaseRoot = Invoke-MyCommand -Command GetDatabaseStorePath
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Reset-DatabaseStore

function Get-DatabaseStore{
    [CmdletBinding()]
    param()

        $databaseRoot = Invoke-MyCommand -Command GetDatabaseStorePath
    
        return $databaseRoot

} Export-ModuleMember -Function Get-DatabaseStore

function Get-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path =  GetDatabaseFile $Key
    
    if(-Not (Test-Path $path)){
        return $null
    }

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Reset-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )
    $path =  GetDatabaseFile -Key $Key
    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key,
        [Parameter(Position = 2)][Object]$Database
    )

    $path = GetDatabaseFile -Key $Key

    $Database | ConvertTo-Json -Depth 10 | Set-Content $path
}

function GetDatabaseFile{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $databaseRoot = Invoke-MyCommand -Command GetDatabaseStorePath

    $path = $databaseRoot | Join-Path -ChildPath "$Key.json"

    return $path
}

function Invoke-ProjectHelperGetDatabaseStorePath{
    [CmdletBinding()]
    param()

    $databaseRoot = $DATABASE_ROOT

    return $databaseRoot
} Export-ModuleMember -Function Invoke-ProjectHelperGetDatabaseStorePath