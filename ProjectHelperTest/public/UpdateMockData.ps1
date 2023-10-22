
function ProjectHelperTest_MockData_Update{

    $whatif = $true
    $localommandList = Get-CommandList
    $mockFilePath = Get-MockFilePath
    
    Update-MockData @InfoParameters -Verbose -WhatIf:$whatif

    Assert-Count -expected $($localommandList.count) -Presented $($infoVar.MessageData | Where-Object {$_.StartsWith('gh')})

    Assert-Contains -Presented $infoVar -Expected 'gh --version'
    Assert-Contains -Presented $infoVar -Expected 'gh issue create --repo rulasg/testPublicRepo --title "Issue Title" --body "Issue Body"'
    Assert-Contains -Presented $infoVar -Expected 'gh project field-list 11 --owner rulasg'
    Assert-Contains -Presented $infoVar -Expected 'gh project item-list 11 --owner rulasg --format json'
    Assert-Contains -Presented $infoVar -Expected 'gh project item-add 11 --owner rulasg --url https://github.com/rulasg/publicrepo/issues/1'
    Assert-Contains -Presented $infoVar -Expected 'gh project item-delete 11 --owner rulasg --id PVTI_lAHOAGkMOM4AUB10zgIiF0E'
    Assert-Contains -Presented $infoVar -Expected 'gh project list --owner rulasg --limit 1000 --format json'    
    Assert-Contains -Presented $infoVar -Expected 'gh project item-edit --project-id 11 --id {1} --field-id {2} --text {3}'
    Assert-Contains -Presented $infoVar -Expected 'gh project item-create 11 --owner rulasg --title "Item Title" --body "Item Body"'

    Assert-Contains -Presented $infoVar -Expected 'gh issue list --repo rulasg/testPublicRepo --json number,title,state,url'

    # Assert-Contains -Presented $infoVar -Expected 'gh repo list rulasg --limit 1000  --no-archived --source --json nameWithOwner'
    # Assert-Contains -Presented $infoVar -Expected 'gh repo edit testPublicRepo --add-t opic topic1,topic2'

    if(-not $whatif){
        # Check that all files exists
        foreach($key in $localommandList.Keys){
            $mockDataExtension = if($localommandList[$key].IsJson){ 'json' } else { 'txt' }
            $filePath = $mockFilePath | Join-Path -ChildPath "$key.$mockDataExtension"
            Assert-FileExists -Path $filePath
        }
    } else {
        Assert-Count -expected $($localommandList.count) -Presented $($infoVar.MessageData | Where-Object {$_.StartsWith('Saving File')})
    }
}

function ProjectHelperTest_MockData_Update_CommandKey{

    $whatif = $true
    $mockFilePath = Get-MockFilePath
    $localommandList = Get-CommandListDefaults
    $key = "Issue_List"

    $commandItem = $localommandList.$key

    Update-MockData -CommandKey $key @InfoParameters -WhatIf:$whatif

    Assert-Count -expected 1 -Presented $($infoVar.MessageData | Where-Object {$_.StartsWith('gh')})

    Assert-Contains -Presented $infoVar -Expected 'gh issue list --repo rulasg/testPublicRepo --json number,title,state,url'

    if(-Not $whatif){
        $mockDataExtension = if($commandItem.IsJson){ 'json' } else { 'txt' }
        $filePath = $mockFilePath | Join-Path -ChildPath "$key.$mockDataExtension"
        Assert-ItemExist -Path $filePath
    }else {
        Assert-Count -expected 1 -Presented $($infoVar.MessageData | Where-Object {$_.StartsWith('Saving File')})
    }
}

function Update-MockData{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # commandkey
        [Parameter()][string]$CommandKey
    )

    $mockFilePath = Get-MockFilePath

    $localCommandList = Get-CommandListDefaults
    # check if CommandKey is nul or white space

    if(-Not [string]::IsNullOrWhiteSpace($CommandKey)){
        $localCommandList = @{ $commandKey = $localCommandList[$CommandKey]}
    }

    $ev = @{
        owner = "rulasg"
        repo = "rulasg/testPublicRepo"
        projectNumber = 11
        projectName = "Public Project"
        issueUrl = "https://github.com/rulasg/publicrepo/issues/1"
        itemId = "PVTI_lAHOAGkMOM4AUB10zgIiF0E"
        topics = "topic1,topic2"
        itemTitle = "Item Title"
        itemBody = "Item Body"
        issueTitle = "Issue Title"
        issueBody = "Issue Body"
        attributes = "attrib1,attrib2,attrib3"
    }

    ForEach ($key in $localCommandList.Keys){

        $command = $localCommandList[$key].Command

        # udpate command with testing parameters
        foreach($item in $ev.Keys){
            $command = $command -replace "{$item}",$ev[$item]
        }

        # Invoke command
        $result = Invoke-TestExpression -Command $command -whatif:$WhatIfPreference

        # Set proper Result value
        if($null -eq $result){
            if($localCommandList[$key].IsJson){
                $result = "[]"
            } else {
                $result = ""
            }
        }

        # Build file path
        $fileExtension = ($localCommandList[$key].IsJson) ? 'json' : 'txt' 
        $fileName = $("{0}.{1}" -f $key.ToLower(),$fileExtension)
        $filePath = $mockFilePath | Join-Path -ChildPath $fileName

        # Save file
        if ($PSCmdlet.ShouldProcess($filePath, "Out-File")) {
            $result | Out-File -FilePath $filePath
        }

        "Saving File $filePath" | Write-Information
    }
}

function Invoke-TestExpression{
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        [Parameter(Mandatory)][string]$Command
    )

    $command | Write-Verbose

    if ($PSCmdlet.ShouldProcess("GH Command", $Command)) {
        $ret = Invoke-Expression -Command $Command
    } else {
        $ret = $null
    }

    $Command | Write-Information

    return $ret
}

