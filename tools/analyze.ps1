<#
.SYNOPSIS
    Analyze PowerShell scripts with PSScriptAnalyzer.
#>

[CmdletBinding()]
param ()

# Install PSScriptAnalyzer if not already installed
$analyzerModule = Get-Module -ListAvailable -Name PSScriptAnalyzer
if ($null -eq $analyzerModule) {
  Install-Module -Name PSScriptAnalyzer -Force
}

# Import PSScriptAnalyzer
Import-Module -Name PSScriptAnalyzer

# Analyze the current folder
# $result = "public","private" | Invoke-ScriptAnalyzer -Recurse -ExcludeRule PSUseToExportFieldsInManifest 
$result = "public","private" | Invoke-ScriptAnalyzer -Recurse -ExcludeRule PSUseToExportFieldsInManifest -Severity Error,Warning

# Output the results
$result