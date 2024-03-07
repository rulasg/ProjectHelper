function ProjectHelperTest_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock

    $Owner = "someOwner" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    # Item id 10
    # $title = "A draft in the project" 

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"

    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment"
    $fieldTitle = "title" ; $fieldTitleValue = "new value of the title"

    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItemsSaved -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-Contains -Expected $itemId -Presented $result.Keys

    Assert-Count -Expected 2 -Presented $result.$itemId
    Assert-Contains -Expected "comment" -Presented $result.$itemId.Keys
    Assert-Contains -Expected "title" -Presented $result.$itemId.Keys

    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.comment.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.title.Value
}