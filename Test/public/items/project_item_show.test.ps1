function Test_Write_Sucess {

    Invoke-PrivateContext {
        Start-Transcript -Path test.log
    
        #Factors to test
        $factors = @(
            @{                     Text = "Test with no other parameters"; ExpectedText = "Test with no other parameters" }
            @{ Color = "Red"; Text = "Red Text"; BetweenQuotes = $false; PreFix = ""; DefaultValue = "(defaultValue)" ; ExpectedText = "Red Text" }
            @{ Color = "Gray"; Text = "Gray Text"; BetweenQuotes = $false; DefaultValue = "(defaultValue)" ; ExpectedText = "Gray Text" }
            @{ Color = "Green"; Text = "Green Text"; BetweenQuotes = $true; PreFix = "Prefix: "; DefaultValue = "(defaultValue)" ; ExpectedText = 'Prefix: "Green Text"' }
            @{ Color = "Blue"; Text = ""; BetweenQuotes = $false; PreFix = "NoText: "; DefaultValue = "(defaultValue)" ; ExpectedText = "NoText: (defaultValue)" }
            @{ Color = "Yellow"; BetweenQuotes = $true; PreFix = "NullText: "; DefaultValue = "(defaultValue)" ; ExpectedText = 'NullText: "(defaultValue)"' }
            @{ Color = "Cyan"; Text = "   "; BetweenQuotes = $false; PreFix = "WhiteSpace: "; ; ExpectedText = "WhiteSpace: (empty)" }
            @{ Color = "Cyan"; Text = "   "; BetweenQuotes = $true; PreFix = "WhiteSpace2: "; ; ExpectedText = 'WhiteSpace2: "(empty)"' }
        )
        
        foreach ($factor in $factors) {
            $color = $factor.Color
            $text = $factor.Text
            $BetweenQuotes = $factor.BetweenQuotes
            $PreFix = $factor.PreFix
            $DefaultValue = $factor.DefaultValue

            # Act

            # Capture the output
            # Call the write function with parameters
            write -color $color -text $text -BetweenQuotes:$BetweenQuotes -PreFix $PreFix -DefaultValue $DefaultValue

        }
        
        # Can not use MyTranscript as we are on a private context that does not hase access to Test private functions
        # Code loggic here to extract from transcript
        Stop-Transcript ;
        $transcriptContent = Get-Content -Path test.log
        $i = 0..($transcriptContent.Count - 1) | Where-Object { $transcriptContent[$_] -eq "**********************" }
        $firstLine = $i[1] + 1 ; $lastLine = $i[2] - 1
        $result = $transcriptContent[$firstLine..$lastLine]
        
        # Assert.
        $assertLine = 0
        foreach ($factor in $factors) {
            Assert-AreEqual -Expected $factor.ExpectedText -Presented $result[$assertLine] 
            $assertLine++
        }
    }
}

function Get-Test_Write_Sucess_Factors {

    return = @(
        @{                     Text = "Test with no other parameters"; ExpectedText = "Test with no other parameters" }
        @{ Color = "Red"; Text = "Red Text"; BetweenQuotes = $false; PreFix = ""; DefaultValue = "(defaultValue)" ; ExpectedText = "Red Text" }
        @{ Color = "Gray"; Text = "Gray Text"; BetweenQuotes = $false; DefaultValue = "(defaultValue)" ; ExpectedText = "Gray Text" }
        @{ Color = "Green"; Text = "Green Text"; BetweenQuotes = $true; PreFix = "Prefix: "; DefaultValue = "(defaultValue)" ; ExpectedText = 'Prefix: "Green Text"' }
        @{ Color = "Blue"; Text = ""; BetweenQuotes = $false; PreFix = "NoText: "; DefaultValue = "(defaultValue)" ; ExpectedText = "NoText: (defaultValue)" }
        @{ Color = "Yellow"; BetweenQuotes = $true; PreFix = "NullText: "; DefaultValue = "(defaultValue)" ; ExpectedText = 'NullText: "(defaultValue)"' }
        @{ Color = "Cyan"; Text = "   "; BetweenQuotes = $false; PreFix = "WhiteSpace: "; ; ExpectedText = "WhiteSpace: (empty)" }
        @{ Color = "Cyan"; Text = "   "; BetweenQuotes = $true; PreFix = "WhiteSpace2: "; ; ExpectedText = 'WhiteSpace2: "(empty)"' }
    )
} Export-ModuleMember -Function Get-Test_Write_Sucess_Factors, Test_Write_Sucess

function Test_ShowProjectItem_SUCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    $i = $p.issue
    MockCall_GetProject $p -skipItems
    MockCall_GetItem $i.Id

    Start-MyTranscript
    $result = $i.id | Show-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -AllComments
    $tt = Stop-MyTranscript

    Assert-IsNull -Object $result

    Assert-Contains -Presented $tt -Expected "# $($i.number)"
    Assert-Contains -Presented $tt -Expected """$($i.title)"""
    Assert-Contains -Presented $tt -Expected "$($i.url)"
    Assert-Contains -Presented $tt -Expected "$($i.status)"
    Assert-Contains -Presented $tt -Expected "$($i.Body)"

    Assert-Contains -Presented $tt -Expected "By: $($i.comments.last.author.login)"
    Assert-Contains -Presented $tt -Expected "At: $($i.comments.last.updatedAt)"
    Assert-Contains -Presented $tt -Expected $i.comments.last.body
    
    Assert-Contains -Presented $tt -Expected $i.id
}

function Test_OpenInEditor{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $text = "Sample Text for Editor"

    $command = '"{content}" | code -w - '
    $command = $command -replace '\{content\}', $text

    MockCallToNull -Command $command

    Invoke-PrivateContext{

         $text = "Sample Text for Editor"

        $result = Open-InEditor -Content $text

        Assert-IsNull -Object $result
    }
    
}