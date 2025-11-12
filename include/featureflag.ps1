# Feature Flag
#
# Feature Flags management module
#
# Include design description
# This module depends on Config Include
# This module will allow set Feature Flags to the module to quicker release 
# features with less risk
#

$MODULE_NAME_PATH = ($PSScriptRoot | Split-Path -Parent | Get-ChildItem -Filter *.psd1 | Select-Object -First 1) | Split-Path -Parent

function Get-FeatureFlags{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    if(! $config){
        return @{}
    }

    if(! $config.FeatureFlags){
        $config.FeatureFlags = @{}
    }

    return $config.FeatureFlags
}

function Save-FeatureFlags{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][hashtable]$FeatureFlags
    )

    $result = Set-ModuleNameConfigValue -Name "FeatureFlags" -Value $FeatureFlags

    if(! $result){
        throw "Failed to save Feature Flags"
    }
}

function Test-FeatureFlag {
    [CmdletBinding()]
    [Alias("tff")]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key
    )

    $ffs = Get-FeatureFlags

    $value = $ffs.$Key

    if($null -eq $value){
        Set-FeatureFlag -Key $Key -Value $false
        return $false
    }

    return $value
}

function Set-FeatureFlag{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key,
        [Parameter()][bool]$Value = $true

    )

    $featureFlags = Get-FeatureFlags

    $featureFlags.$Key = $Value

    Save-FeatureFlags $featureFlags

}

function Clear-FeatureFlag{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key

    )

    Set-FeatureFlag -Key $Key -Value $false

}

######

# function Get-ModuleNameRegisteredFeatureFlags{
#     [cmdletbinding()]
#     param()

#     $ffPath = $MODULE_NAME_PATH | Join-Path -ChildPath "featureflags.json"

#     if(! ($ffPath | Test-Path)){
#         return
#     }

#     $Json = Get-Content $ffPath 

#     $ff = $Json | ConvertFrom-Json

#     return $ff

# }
# $function = "Get-ModuleNameRegisteredFeatureFlags"
# $destFunction = $function -replace "ModuleName", $MODULE_NAME
# if( -not (Test-Path function:$destFunction )){
#     Rename-Item -path Function:$function -NewName $destFunction
#     Export-ModuleMember -Function $destFunction
# }

function Get-ModuleNameFeatureFlags{
    [cmdletbinding()]
    param()

    $ffs = Get-FeatureFlags

    return $ffs
}
$function = "Get-ModuleNameFeatureFlags"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    Rename-Item -path Function:$function -NewName $destFunction
    Export-ModuleMember -Function $destFunction
}

function Set-ModuleNameFeatureFlag{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key,
        [Parameter()][bool]$Value = $true
    )

    Set-FeatureFlag -Key $Key -Value $Value
}
$function = "Set-ModuleNameFeatureFlag"
$destFunction = $function -replace "ModuleName", $MODULE_NAME
if( -not (Test-Path function:$destFunction )){
    Rename-Item -path Function:$function -NewName $destFunction
    Export-ModuleMember -Function $destFunction
}
