<#
.SYNOPSIS
    Run tests
.DESCRIPTION
    Run the unit test of the actual module
.NOTES
    Using TestingHelper this script will search for a Test module and run the tests
    This script will be referenced from launch.json to run the tests on VSCode
.LINK
    https://raw.githubusercontent.com/rulasg/StagingModule/main/test.ps1
.EXAMPLE
    > ./test.ps1
#>

[CmdletBinding()]
param (
    [Parameter()][switch]$ShowTestErrors,
    [Parameter()][string]$TestName
)

function Import-RequiredModule{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Scope='Function')]
    param (
        [Parameter(ParameterSetName = "HT", ValueFromPipeline)][hashtable]$RequiredModule,
        [Parameter(ParameterSetName = "RM",Position = 0)][string]$ModuleName,
        [Parameter(ParameterSetName = "RM")][string]$ModuleVersion,
        [Parameter(ParameterSetName = "HT")]
        [Parameter(ParameterSetName = "RM")]
        [switch]$AllowPrerelease,
        [Parameter(ParameterSetName = "HT")]
        [Parameter(ParameterSetName = "RM")]
        [switch]$PassThru
    )

    process{
        # Powershell module manifest does not allow versions with prerelease tags on them. 
        # Powershell modle manifest does not allow to add a arbitrary field to specify prerelease versions.
        # Valid value (ModuleName, ModuleVersion, RequiredVersion, GUID)
        # There is no way to specify a prerelease required module.

        if($RequiredModule){
            $ModuleName = $RequiredModule.ModuleName
            $ModuleVersion = [string]::IsNullOrWhiteSpace($RequiredModule.RequiredVersion) ? $RequiredModule.ModuleVersion : $RequiredModule.RequiredVersion
        }

        "Importing module Name[{0}] Version[{1}] AllowPrerelease[{2}]" -f $ModuleName, $ModuleVersion, $AllowPrerelease | Write-Verbose

        # Following semVer we can manually specidy a taged version to specify that is prerelease
        # Extract the semVer from it and set AllowPrerelease to true
        if ($ModuleVersion) {
            $V = $ModuleVersion.Split('-')
            $semVer = $V[0]
            $AllowPrerelease = ($AllowPrerelease -or ($null -ne $V[1]))
        }

        $module = Import-Module $ModuleName -PassThru -ErrorAction SilentlyContinue -MinimumVersion:$semVer

        if ($null -eq $module) {
            "Installing module Name[{0}] Version[{1}] AllowPrerelease[{2}]" -f $ModuleName, $ModuleVersion, $AllowPrerelease | Write-Host -ForegroundColor DarkGray
            $installed = Install-Module -Name $ModuleName -Force -AllowPrerelease:$AllowPrerelease -passThru -RequiredVersion:$ModuleVersion
            $module = $installed | ForEach-Object {Import-Module -Name $_.Name -RequiredVersion ($_.Version.Split('-')[0]) -Force -PassThru}
        }

        "Imported module Name[{0}] Version[{1}] PreRelease[{2}]" -f $module.Name, $module.Version, $module.privatedata.psdata.prerelease | Write-Host -ForegroundColor DarkGray

        if ($PassThru) {
            $module
        }
    }
}

function Test-TestingHelperResults{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][object]$result,
        [Parameter()][switch]$SkippedNotAllowed,
        [Parameter()][switch]$NotImplementedNotAllowed
    )

    # Chek results from last run
    $result = $result ?? $Global:ResultTestingHelper

    if($SkippedNotAllowed -and $result.Skipped -gt 0){
        return $false
    }

    if($NotImplementedNotAllowed -and $result.NotImplemented -gt 0){
        return $false
    }

    # Allow Not Implemented and Skipped tests to pass
    $passed = $result.Tests -eq $result.Pass + $result.NotImplemented + $result.Skipped

    return $passed
}

<#
. SYNOPSIS
    Extracts the required modules from the module manifest
#>
function Get-RequiredModule{
    [CmdletBinding()]
    [OutputType([Object[]])]
    param()

    # Required Modules
    $localPath = $PSScriptRoot
    $manifest = $localPath | Join-Path -child "*.psd1" |  Get-Item | Import-PowerShellDataFile
    $requiredModule = $null -eq $manifest.RequiredModules ? @() : $manifest.RequiredModules

    # Convert to hashtable
    $ret = @()
    $requiredModule | ForEach-Object{
        $ret += $_ -is [string] ? @{ ModuleName = $_ } : $_
    }

    return $ret
}

# Install and load TestingHelper
# Import-RequiredModule -Name TestingHelper -AllowPrerelease
Import-RequiredModule "TestingHelper" -AllowPrerelease

# Install and Load Module dependencies
Get-RequiredModule | Import-RequiredModule -AllowPrerelease

# Resolve scoped tests
$TestName = [string]::IsNullOrWhiteSpace($TestName) ? $global:TestNameVar : $TestName

# Call TestingHelper to run the tests
Invoke-TestingHelper -TestName $TestName -ShowTestErrors:$ShowTestErrors

