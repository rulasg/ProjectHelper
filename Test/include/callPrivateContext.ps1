# CALL PRIVATE FUNCTIONS
#
# This file enables tests to invoke private (non-exported) functions
# defined inside the main module by evaluating a provided scriptblock
# in the module context.
#
# It relies on variables initialized by module.helper.ps1.
# REQUIRED:
#   $MODULE_PATH  - Full path to the module .psm1 file (or a file inside its folder)
#
# THIS INCLUDE REQUIRES module.helper.ps1
if(-not $MODULE_PATH){ throw "Missing MODULE_PATH variable initialization. Check for module.helper.ps1 file." }

function Invoke-PrivateContext {
    param (
        [Parameter(Mandatory, Position = 0)]
        [scriptblock]$ScriptBlock,
        [string]$ModulePath
    )

    if ([string]::IsNullOrEmpty($ModulePath)) {
        $modulePath = $MODULE_PATH | Split-Path -Parent
    }

    $module = Import-Module -Name $modulePath -PassThru

    if ($null -eq $module) {
        throw "Failed to import the main module."
    }

    & $module $ScriptBlock
} Export-ModuleMember -Function Invoke-PrivateContext
