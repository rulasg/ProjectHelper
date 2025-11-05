
# SET MY INVOKE COMMAND ALIAS
#
# Allows calling constitely InvokeHelper with the module tag
# Need to define a variable called $MODULE_INVOKATION_TAG
#

$moduleRootPath = $PSScriptRoot | Split-Path -Parent
$MODULE_NAME = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName
$MODULE_INVOKATION_TAG = "$($MODULE_NAME)Module"

function Set-MyInvokeCommandAlias{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    if ($PSCmdlet.ShouldProcess("InvokeCommandAliasList", ("Add Command Alias [{0}] = [{1}]" -f $Alias, $Command))) {
        InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG
    }
}

function Invoke-MyCommand{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$Command,
        [Parameter(Position=1)][hashtable]$Parameters
    )

    Write-MyDebug "invoke" $Command $Parameters

    return InvokeHelper\Invoke-MyCommand -Command $Command -Parameters $Parameters
}


function Reset-MyInvokeCommandAlias{
    [CmdletBinding(SupportsShouldProcess)]
    param()

        # throw if MODULE_INVOKATION_TAG is not set or is "MyModuleModule"
    if (-not $MODULE_INVOKATION_TAG) {
        throw "MODULE_INVOKATION_TAG is not set. Please set it to a unique value before calling Set-MyInvokeCommandAlias."
    }
    InvokeHelper\Reset-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG
}

# Reset all aliases for this module on each refresh
Reset-MyInvokeCommandAlias
