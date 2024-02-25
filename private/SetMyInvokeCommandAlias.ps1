# Managing dependencies

# Gate to be loaded only onces
if (!$SET_MY_INVOKECOMMANDALIAS_LOADED){
    $SET_MY_INVOKECOMMANDALIAS_LOADED = $true

    $MODULE_INVOKATION_TAG = "ProjectHelperModule"

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

}