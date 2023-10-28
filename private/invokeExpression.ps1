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

    # Check if result is null or whitespace
    if([string]::IsNullOrWhiteSpace($result)){
        $ret = '[]'
    } else {
        $ret = $result
    }

    $ret = $result | ConvertFrom-Json

    return $ret
}
