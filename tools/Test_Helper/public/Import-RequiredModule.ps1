<#
.SYNOPSIS
    Import required modules
.DESCRIPTION
    Import required modules specified in a module manifest or by name/version
    If the module is not installed it will be installed from PSGallery
#>

function Import-RequiredModule{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Scope='Function')]
    param (
        [Parameter(ParameterSetName = "HT", ValueFromPipeline)][PsCustomObject]$RequiredModule,
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
} Export-ModuleMember -Function Import-RequiredModule
