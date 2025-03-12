
function Test_GetProjectItem_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    $fieldComment = "Comment" ; $fieldTitle = "Title"

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields"

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldTitleValue = "A draft in the project"
    $fieldCommentValue = "This"

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle

    # Edit to see the staged references
    $fieldCommentValue = "new value of the comment 10.1"
    $fieldTitleValue = "new value of the title 10.1"
    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle
}

function Test_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields"
    
    Mock_DatabaseRoot
    # Item id 10
    # $title = "A draft in the project" 

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $title_fieldid= "PVTF_lADOBCrGTM4ActQazgSkYm8"
    $comment_fieldid = "PVTF_lADOBCrGTM4ActQazgSl5GU"

    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment 10.1"
    $fieldTitle = "title" ; $fieldTitleValue = "new value of the title 10.1"

    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-Contains -Expected $itemId -Presented $result.Keys

    Assert-Count -Expected 2 -Presented $result.$itemId
    Assert-AreEqual -Expected "Comment" -Presented $result.$itemId.$comment_fieldid.Field.name
    Assert-AreEqual -Expected "Title" -Presented $result.$itemId.$title_fieldid.Field.name 

    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$comment_fieldid.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.$title_fieldid.Value
}

function Test_UpdateProjectDatabase_Fail_With_Staged{
    # When changes are staged list update should fail.
    # As Update-ProjectDatabase is a private function, we will test it through the public function Get-ProjectItemList with Force

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ;
    $itemId = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment 10.1"
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields"


    # Calling Get-ProjectItemList with Force to trigger update-projectdatabase that should fail as their are 
    # staged changes not yet synced to remote.
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

    $result = Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Assert-IsNull -Object $result

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys

    # This call should fail as there are staged changes
    Start-MyTranscript
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $tt = Stop-MyTranscript

    Assert-IsNull -Object $result
    $message = "Error: Can not get item list with Force [True]; There are unsaved changes. Restore changes with Reset-ProjectItemStaged or sync projects with Sync-ProjectItemStaged first and try again"
    Assert-Contains -Expected $message -Presented $tt

    # Reset the staged changes
    Reset-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $result.Keys
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

}

