
function Test_CommitProjectItemsStaged_NoStaged{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields_SomeOrg_164

    Start-MyTranscript
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    $t = Stop-MyTranscript

    Assert-Contains -Presented $t -Expected "Nothing to commit"
    Assert-IsNull -Object $result
}

function Test_CommitProjectItemsStaged_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # Item id 10
    # Name                           Value
    # ----                           -----
    # id                             PVTI_lADOBCrGTM4ActQazgMuXXc
    # number                         
    # Severity                       Nice⭐️
    # Status                         Todo
    # TimeTracker                    890
    # Comment                        This
    # body                           some content in body
    # Assignees                      rulasg
    # UserStories                    8
    # Title                          A draft in the project
    # Priority                       🥵High
    # url                            
    # type                           DraftIssue

    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldComment1 = "Comment" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"

    # Name                           Value
    # ----                           -----
    # number                         6
    # id                             PVTI_lADOBCrGTM4ActQazgMueM4
    # body                           
    # type                           PullRequest
    # Start Date                     2024-02-23
    # Repository                     https://github.com/SolidifyDemo/ProjectDemoTest-repo-front
    # Title                          Update README.md
    # Assignees                      rulasg
    # TimeTracker                    888
    # Status                         In Progress
    # Next Action Date               2024-02-23
    # url                            https://github.com/SolidifyDemo/ProjectDemoTest-repo-front/pull/6
    # $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    $itemId2 = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment2 = "Comment" ; $fileCommentValue2 = "new value of the comment 11"
    $fieldTitle2 = "Title" ; $fileTitleValue2 = "new value of the title 11"

    MockCall_GitHubOrgProjectWithFields_SomeOrg_164
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTF_lADOBCrGTM4ActQazgSl5GU -Value "new value of the comment 10" -Type text'
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTF_lADOBCrGTM4ActQazgSkYm8 -Value "new value of the title" -Type text'
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMueM4 -FieldId PVTF_lADOBCrGTM4ActQazgSl5GU -Value "new value of the comment 11" -Type text'
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMueM4 -FieldId PVTF_lADOBCrGTM4ActQazgSkYm8 -Value "new value of the title 11" -Type text'

    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldComment2 $fileCommentValue2
    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldTitle2 $fileTitleValue2

    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1

    $item2 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId2
    Assert-AreEqual -Expected $fileCommentValue2 -Presented $item2.$fieldComment2
    Assert-AreEqual -Expected $fileTitleValue2 -Presented $item2.$fieldTitle2
}


function Test_ShowProjectItemsStaged{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields_SomeOrg_164

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $result

    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldComment1 = "comment" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "title" ; $fieldTitleValue1 = "new value of the title"
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1

    $itemId2 = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment2 = "comment" ; $fileCommentValue2 = "new value of the comment 11"
    $fieldTitle2 = "title" ; $fileTitleValue2 = "new value of the title 11"
    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldComment2 $fileCommentValue2
    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldTitle2 $fileTitleValue2

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber

    $result1 = $result | Where-Object { $_.id -eq $itemId1 }
    Assert-AreEqual -Expected "DraftIssue" -Presented $result1.type
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $result1.Fields.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $result1.Fields.$fieldTitle1
    
    $result2 = $result | Where-Object { $_.id -eq $itemId2 }
    Assert-AreEqual -Expected "PullRequest" -Presented $result2.type
    Assert-AreEqual -Expected $fileCommentValue2 -Presented $result2.Fields.$fieldComment2
    Assert-AreEqual -Expected $fileTitleValue2 -Presented $result2.Fields.$fieldTitle2
}
