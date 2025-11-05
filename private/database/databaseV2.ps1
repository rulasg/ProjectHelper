# Not using Include version as we moved away from the generic include version

# Invoke to allow mockig the store path on testing
Set-MyInvokeCommandAlias -Alias GetDatabaseStorePath -Command "Invoke-ProjectHelperGetDatabaseStorePath"

$DATABASE_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "databaseCache"

# Create the database root if it does not exist
if (-Not (Test-Path $DATABASE_ROOT)) {
    New-Item -Path $DATABASE_ROOT -ItemType Directory
}

function Reset-DatabaseStore {
    [CmdletBinding()]
    param()

    $databaseRoot = Get-DatabaseStore -Force

    Microsoft.PowerShell.Management\Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

    New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Reset-DatabaseStore

function Get-DatabaseStore {
    [CmdletBinding()]
    param(
        [switch] $Force
    )

    if ($Force -or -Not $script:databaseRoot) {
        $script:databaseRoot = Invoke-MyCommand -Command GetDatabaseStorePath
        "Using DatabaseStore path: $script:databaseRoot" | Write-MyDebug -Section DatabaseStore
    }

    return $script:databaseRoot

} Export-ModuleMember -Function Get-DatabaseStore

function Get-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path = Get-DatabaseFile $Key

    if (-Not (Test-Path $path)) {
        return $null
    }

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Reset-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )
    $path = Get-DatabaseFile -Key $Key
    Microsoft.PowerShell.Management\Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key,
        [Parameter(Position = 2)][Object]$Database
    )

    $path = Get-DatabaseFile -Key $Key

    "Saving database to $path" | Write-MyDebug -Section Database

    $Database | ConvertTo-Json -Depth 10 | Set-Content $path
}

function Get-DatabaseFile {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $databaseRoot = Get-DatabaseStore

    $path = $databaseRoot | Join-Path -ChildPath "$Key.json"

    return $path
}

function Invoke-ProjectHelperGetDatabaseStorePath {
    [CmdletBinding()]
    param()

    $databaseRoot = $DATABASE_ROOT

    return $databaseRoot
} Export-ModuleMember -Function Invoke-ProjectHelperGetDatabaseStorePath