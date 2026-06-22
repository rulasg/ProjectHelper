function Test_QuickCommands_InvokeQQ_Help {

    $commandPattern = "Invoke-QQ*"

    # Act

    ## Get help command
    $help = Invoke-QQ_Help

    ## Get actual commands with the pattern
    $alias = get-alias | Where-Object {$_.ReferencedCommand -like $commandPattern}

    # Help count and alias count match
    Assert-Count -Expected $help.Count -Presented $alias

    # check that alias and command match
    $help.QQ_Cmd | Assert-QQCommand
}

function Assert-QQCommand{
    param(
        [Parameter(ValueFromPipeline)][string]$Name
    )

    process{
        # Get command
        $alia = get-alias -Name $Name -ErrorAction SilentlyContinue
        
        # confirm that their is a valir referenced command
        $result = Get-Command $alia.ReferencedCommand -ErrorAction SilentlyContinue
        Assert-IsNotNull -Object $result
    }
}