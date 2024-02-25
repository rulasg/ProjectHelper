Set-MyInvokeCommandAlias -Alias HELLO_WORLD -Command 'echo "Hello World"'

<#
.SYNOPSIS
    Get Hello World message
#>
function Get-HelloWorld{
    [CmdletBinding()]
    param(
    )

    $result = Invoke-MyCommand -Command HELLO_WORLD
    return $result

} Export-ModuleMember -Function Get-HelloWorld
