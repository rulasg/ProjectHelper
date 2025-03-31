
function Test_CommitProjectItemsStaged_NoStaged{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

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

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
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
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $result

    $projectBefore = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Item 1
    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    
    $fieldComment1 = "Comment" ; $fieldCommentValue1 = "new value of the comment 10" 
    $fieldCommentValue1_Before = $projectBefore.items.$itemId1.$fieldComment1
    
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title" 
    $fieldTitleValue1_Before = $projectBefore.items.$itemId1.$fieldTitle1

    $fieldStatus = "Status" ; $fieldStatusValue1 = "Done"
    $fieldStatusValue1_Before = $projectBefore.items.$itemId1.$fieldStatus

    $fieldDate = "Next Action Date" ; $fieldDateValue1 = "2024-03-31"
    $fieldDateValue1_Before = $projectBefore.items.$itemId1.$fieldDate
    
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldStatus $fieldStatusValue1
    Edit-ProjectItem $owner $projectNumber $itemId1 $fieldDate $fieldDateValue1
    
    # Item 2
    $itemId2 = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment2 = "Comment" ; $fileCommentValue2 = "new value of the comment 11"
    $fieldTitle2 = "Title" ; $fileTitleValue2 = "new value of the title 11"

    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldComment2 $fileCommentValue2
    Edit-ProjectItem $owner $projectNumber $itemId2 $fieldTitle2 $fileTitleValue2

    # Act all staged items
    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 2 -Presented $result

    $result1 = $result | Where-Object { $_.id -eq $itemId1 }
    # Assert-AreEqual -Expected "DraftIssue" -Presented $result1.type
    Assert-Contains -Expected $fieldComment1 -Presented $result1.FieldsName
    Assert-Contains -Expected $fieldTitle1 -Presented $result1.FieldsName
    Assert-Contains -Expected $fieldStatus -Presented $result1.FieldsName
    
    $result2 = $result | Where-Object { $_.id -eq $itemId2 }
    # Assert-AreEqual -Expected "PullRequest" -Presented $result2.type
    Assert-Contains -Expected $fieldComment2 -Presented $result2.FieldsName
    Assert-Contains -Expected $fieldTitle2 -Presented $result2.FieldsName

    # Act single item

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber -Id $itemId1

    Assert-Count -Expected 4 -Presented $result

    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $result.$fieldComment1.Value
    Assert-AreEqual -Expected $fieldCommentValue1_Before -Presented $result.$fieldComment1.Before

    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $result.$fieldTitle1.Value
    Assert-AreEqual -Expected $fieldTitleValue1_Before -Presented $result.$fieldTitle1.Before

    Assert-AreEqual -Expected $fieldStatusValue1 -Presented $result.$fieldStatus.Value
    Assert-AreEqual -Expected $fieldStatusValue1_Before -Presented $result.$fieldStatus.Before

    Assert-AreEqual -Expected $fieldDateValue1 -Presented $result.$fieldDate.Value
    Assert-AreEqual -Expected $fieldDateValue1_Before -Presented $result.$fieldDate.Before
}


function Test_TestProjectItemStaged{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # no project information available
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Project is cached
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $null = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Edit some thing
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTF_lADOBCrGTM4ActQazgSl5GU -Value "new value of the comment 10" -Type text'
    Edit-ProjectItem $owner $projectNumber PVTI_lADOBCrGTM4ActQazgMuXXc "Comment" "new value of the comment 10"

    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsTrue -Condition $result

}