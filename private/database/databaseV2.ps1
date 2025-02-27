# Database driver to store and cacche project content and schema

Set-MyInvokeCommandAlias -Alias GetDatabaseStorePath -Command "Invoke-GetDatabaseStorePath"

function Reset-DatabaseRoot{
    [CmdletBinding()]
    param()

        $databaseRoot = Invoke-MyCommand -Command GetDatabaseStorePath
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Reset-DatabaseRoot

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

function Invoke-GetDatabaseStorePath{
    [CmdletBinding()]
    param()

    $databaseRoot = "~/.helpers/projecthelper/databaseV2"

    return $databaseRoot
} Export-ModuleMember -Function Invoke-GetDatabaseStorePath