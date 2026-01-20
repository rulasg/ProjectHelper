function Set-TestName{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope='Function')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [Alias("st")]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$TestName
    )

    process{
        $global:TestNameVar = $TestName
    }
} Export-ModuleMember -Function Set-TestName -Alias st

function Get-TestName{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope='Function')]
    [Alias("gt")]
    param (
    )

    process{
        $global:TestNameVar
    }
} Export-ModuleMember -Function Get-TestName -Alias gt

function Clear-TestName{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope='Function')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    [Alias("ct")]
    param (
    )

    $global:TestNameVar = $null
} Export-ModuleMember -Function Clear-TestName -Alias ct