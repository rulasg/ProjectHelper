function Build-GhCommand{
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory, Position = 0)][string]$GhCommandKey,
        [Parameter(Position = 1)][string]$Parameter0,
        [Parameter(Position = 2)][string]$Parameter1,
        [Parameter(Position = 3)][string]$Parameter2
    )

    $expression = $global:GhCommands.$GhCommandKey

    $ret = $expression -f $Parameter0,$Parameter1,$Parameter3

    return $ret
} Export-ModuleMember -Function Build-GhExpresion

