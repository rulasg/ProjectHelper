<#
. SYNOPSIS
    Extracts the required modules from the module manifest
#>
function Get-RequiredModule{
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        # Path
        [Parameter()][string]$Path = '.'
    )

    # Required Modules
    $manifest = $Path | Join-Path -child "*.psd1" | Get-Item | Import-PowerShellDataFile
    $requiredModule = $null -eq $manifest.RequiredModules ? @() : $manifest.RequiredModules

    "Found RequiredModules: $($requiredModule.Count)" | Write-Host -ForegroundColor DarkGray

    # Convert to hashtable
    $requiredModule | ForEach-Object{
        "Processing RequiredModule: $($_| convertto-json -Depth 5)" | Write-Host -ForegroundColor DarkGray
        $hashtable = $_ -is [string] ? @{ ModuleName = $_ } : $_

        return [pscustomobject]$hashtable
    }

} Export-ModuleMember -Function Get-RequiredModule