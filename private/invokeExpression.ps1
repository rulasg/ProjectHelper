<#
.SYNOPSIS
    Invokes a command expression
#>
function Invoke-GhExpression{
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        [Parameter(Mandatory)][string]$Command
    )

    # $commandScript = [scriptblock]::Create($Command)
    # Invoke-command -ScriptBlock $commandScript
    $ret = $null

    $Command | Write-Information

    if ($PSCmdlet.ShouldProcess("GH Command", $Command)) {
        $ret = Invoke-Expression -Command $Command
    }

    return $ret
}

<#
.SYNOPSIS
    Invokes a command expression and converts the output to json
#>
function Invoke-GhExpressionToJson{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Command
    )

    $result = Invoke-GhExpression -Command $Command

    $ret = $null -eq $result ? $null : $result | ConvertFrom-Json

    return $ret
}
