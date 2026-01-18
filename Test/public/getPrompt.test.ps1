function Test_GetProjecthelperPrompt {

    $owner = "octodemo"
    $projectNumber = "625"
    $s = $ProjecthelperPromoptSettings

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-octodemo-625-skipitems.json" -SkipItems
    MockCallJson -Command 'Invoke-GetItem -itemid id1' -FileName "invoke-getitem-id1.json"
    MockCallJson -Command 'Invoke-GetItem -itemid id2' -FileName "invoke-getitem-id2.json"

    # No environment, return null
    $result = Invoke-WriteProjecthelperPrompt
    Assert-IsNull -Object $(($result | select-string -Pattern "^\[$" ).LineNumber)

    # No environment, with new line
    $result = Invoke-WriteProjecthelperPrompt -WithNewLine
    Assert-IsNull -Object $(($result | select-string -Pattern "^\[$" ).LineNumber)

    # Set environment with empty values
    Set-ProjectHelperEnvironment -Owner $owner -ProjectNumber $projectNumber

    # With environment, without new line
    $result = Invoke-WriteProjecthelperPrompt
    # Find the line with '[' character
    $resultLine = ($result | select-string -Pattern "^\[$" ).LineNumber

    Assert-AreEqual -Presented $result[$resultLine - 1] -Expected $s.BeforeStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine]     -Expected $($($s.OwnerStatus.PreText)+$owner)
    Assert-AreEqual -Presented $result[$resultLine + 1] -Expected $s.DelimStatus1.PreText
    Assert-AreEqual -Presented $result[$resultLine + 2] -Expected $($($s.NumberStatus.PreText)+$projectNumber)
    Assert-AreEqual -Presented $result[$resultLine + 3] -Expected "" # $s.DelimStatus2.PreText is " " that is converted to "" by posh-git"
    Assert-AreEqual -Presented $result[$resultLine + 4] -Expected $s.OKStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine + 5] -Expected $s.AfterStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine + 6] -Expected "" # $s.SpaceStatus.PreText " " that is converted to "" by posh-git

    # With environment, without new line
    $result = Invoke-WriteProjecthelperPrompt -withnewline
    # Find the line with '[' character
    $resultLine = ($result | select-string -Pattern "^\[$" ).LineNumber

    Assert-AreEqual -Presented $result[$resultLine - 1] -Expected $s.BeforeStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine]     -Expected $($($s.OwnerStatus.PreText)+$owner)
    Assert-AreEqual -Presented $result[$resultLine + 1] -Expected $s.DelimStatus1.PreText
    Assert-AreEqual -Presented $result[$resultLine + 2] -Expected $($($s.NumberStatus.PreText)+$projectNumber)
    Assert-AreEqual -Presented $result[$resultLine + 3] -Expected "" # $s.DelimStatus2.PreText is " " that is converted to "" by posh-git"
    Assert-AreEqual -Presented $result[$resultLine + 4] -Expected $s.OKStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine + 5] -Expected $s.AfterStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine + 6] -Expected "" # SpaceStatus.PreText
    Assert-AreEqual -Presented $result[$resultLine + 7] -Expected $s.NewlineStatus.PreText

    # Add some staged items
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId "id1" -FieldName "sf_Text1" -Value "value1"
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId "id1" -FieldName "sf_Text2" -Value "value2"
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId "id2" -FieldName "sf_Text1" -Value "value1"
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId "id2" -FieldName "sf_Text2" -Value "value2"
    $itemstaged = 4

    # With items staged
    $result = Invoke-WriteProjecthelperPrompt
    # Find the line with '[' character
    $resultLine = ($result | select-string -Pattern "^\[$" ).LineNumber

    Assert-AreEqual -Presented $result[$resultLine + 4] -Expected $($($s.KOStatus.PreText)+$itemstaged)

}

function Invoke-WriteProjecthelperPrompt([Switch]$withnewline) {
    $resultFile = "./session_log.txt"

    Start-Transcript -Path $resultFile
    $result = Write-ProjecthelperPrompt -WithNewLine:$withnewline
    Stop-Transcript

    Assert-IsNull -Object $result

    $result = Get-Content $resultFile

    Remove-Item $resultFile -Force

    return $result
}