function ProjectHelperTest_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock
    Initialize-DatabaseRoot
    
    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields"
    
    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

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
    Assert-AreEqual -Expected "Comment" -Presented $result.$itemId.$comment_fieldid.Field.Name
    Assert-AreEqual -Expected "Title" -Presented $result.$itemId.$title_fieldid.Field.Name 

    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$comment_fieldid.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.$title_fieldid.Value
}