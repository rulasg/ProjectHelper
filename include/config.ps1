# CONFIG
#
# Configuration management module
#
# Include design description
# This is the function ps1. This file is the same for all modules.
# Create a public psq with variables, Set-MyInvokeCommandAlias call and Invoke public function.
# Invoke function will call back `GetConfigRootPath` to use production root path
# Mock this Invoke function with Set-MyInvokeCommandAlias to set the Store elsewhere
# This ps1 has function `GetConfigFile` that will call `Invoke-MyCommand -Command $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS`
# to use the store path, mocked or not, to create the final store file name.
# All functions of this ps1 will depend on `GetConfigFile` for functionality.
#

# MODULE_NAME
$MODULE_NAME_PATH = ($PSScriptRoot | Split-Path -Parent | Get-ChildItem -Filter *.psd1 | Select-Object -First 1) | Split-Path -Parent
$MODULE_NAME = $MODULE_NAME_PATH | Split-Path -LeafBase

if(-Not $MODULE_NAME){ throw "Module name not found. Please check the module structure." }

$CONFIG_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "config"

# Create the config root if it does not exist
if(-Not (Test-Path $CONFIG_ROOT)){
    New-Item -Path $CONFIG_ROOT -ItemType Directory
}

function GetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = $CONFIG_ROOT
    return $configRoot
}

function GetConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Key
    )

    $configRoot = Invoke-MyCommand -Command $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS
    $path = Join-Path -Path $configRoot -ChildPath "$Key.json"
    return $path
}

function Test-ConfigurationFile {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    $path = GetConfigFile -Key $Key

    return Test-Path $path
}

function Get-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    # Check for cached configuration
    $configVar = Get-Variable -scope Script -Name "config-$Key" -ErrorAction SilentlyContinue
    if($configVar){
        return $configVar
    }

    # No cached configuration; read from file
    $path = GetConfigFile -Key $Key

    if(-Not (Test-ConfigurationFile -Key $Key)){
        return $null
    }

    try{
        $ret = Get-Content $path | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        return $ret
    }
    catch{
        Write-Warning "Error reading configuration ($Key) file: $($path). $($_.Exception.Message)"
        return $null
    }
}

function Save-Configuration {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Key = "config",
        [Parameter(Mandatory = $true, Position = 1)][Object]$Config
    )

    $path = GetConfigFile -Key $Key

    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $path -ErrorAction Stop
    }
    catch {
        Write-Warning "Error saving configuration ($Key) to file: $($path). $($_.Exception.Message)"
        return $false
    }
    finally{
        Remove-Variable -Scope Script -Name "config-$Key" -ErrorAction SilentlyContinue
    }

    return $true
}

############


# Define unique aliases for "ModuleName"
$CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "$($MODULE_NAME)GetConfigRootPath"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-$($MODULE_NAME)GetConfigRootPath"

# Set the alias for the root path command
Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD

# Define the function to get the configuration root path
function Invoke-ModuleNameGetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = GetConfigRootPath
    return $configRoot
}
$function = "Invoke-ModuleNameGetConfigRootPath"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    Copy-Item -path Function:$function -Destination Function:$destFunction
    Export-ModuleMember -Function $destFunction
}

# Extra functions not needed by INCLUDE CONFIG

function Get-ModuleNameConfig{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    return $config
}
$function = "Get-ModuleNameConfig"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    Copy-Item -path Function:$function -Destination Function:$destFunction
    Export-ModuleMember -Function $destFunction
}

function Open-ModuleNameConfig{
    [CmdletBinding()]
    param()

    $path = GetConfigFile -Key "config"

    code $path
}
$function = "Open-ModuleNameConfig"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    Copy-Item -path Function:$function -Destination Function:$destFunction
    Export-ModuleMember -Function $destFunction
}

function Set-ModuleNameConfigValue{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $config = Get-Configuration

    if(-Not $config){
        $config = @{}
    }

    $config.$Name = $Value

    Save-Configuration -Key "config" -Config $config
}
$function = "Set-ModuleNameConfigValue"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    # Rename-Item -path Function:$function -NewName $destFunction
    Copy-Item -path Function:$function -Destination Function:$destFunction
    Export-ModuleMember -Function $destFunction
}