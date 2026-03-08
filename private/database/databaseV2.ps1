# Not using Include version as we moved away from the generic include version

# Invoke to allow mockig the store path on testing

$aliasName = $MODULE_NAME+ "GetDatabaseStorePath"
Set-MyInvokeCommandAlias -Alias "$aliasName" -Command "Invoke-ProjectHelperGetDatabaseStorePath"

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

    $script:databaseRoot = $null

} Export-ModuleMember -Function Reset-DatabaseStore

function Get-DatabaseStore {
    [CmdletBinding()]
    param(
        [switch] $Force
    )

    if ($Force -or -Not $script:databaseRoot) {
        $script:databaseRoot = Invoke-MyCommand -Command $aliasName
        "Using DatabaseStore path: $script:databaseRoot" | Write-MyDebug -Section DatabaseStore
    }

    return $script:databaseRoot

} Export-ModuleMember -Function Get-DatabaseStore

function Get-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    "Getting database for key [$Key]" | Write-MyDebug -Section Database

    $path = Get-DatabaseFile $Key

    if (-Not (Test-Path $path)) {
        return $null
    }

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Test-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path = Get-DatabaseFile -Key $Key

    $ret = Test-Path $path
    
    "Test [$ret] database for key [$Key] at path [$path]" | Write-MyDebug -Section Database

    return $ret
}

function Reset-Database {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path = Get-DatabaseFile -Key $Key
    
    "Resetting database for key [$Key] at path [$path]" | Write-MyDebug -Section Database

    Microsoft.PowerShell.Management\Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
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

function Get-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
         [Parameter(Position = 2)][string] $Category
    )

    if([string]::IsNullOrWhiteSpace($Owner)){
        throw "Owner is null or empty"
    }
    if($ProjectNumber -le 0){
        throw "ProjectNumber is null or not a positive integer"
    }
    if([string]::IsNullOrWhiteSpace($Category)){
        throw "Category is null or empty"
    }

    $ret = "db-{0}-{1}-{2}" -f $Owner, $ProjectNumber, $Category

    return $ret
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