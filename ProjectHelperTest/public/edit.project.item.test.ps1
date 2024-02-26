function ProjectHelperTest_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock

    $owner = "someOwner" ; $projectNumber = 666 ; $title = "Item 1 - title" ; $itemId = "PVTI_lAHOAGkMOM4AUB10zgIiBZs"
    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment"
    $fieldTitle = "title" ; $fieldTitleValue = "new value of the title"

    MockCall -Command "gh project item-list $ProjectNumber --owner $owner --format json" -filename project_item_list_3.json
    MockCall -Command "gh project field-list $ProjectNumber --owner $owner --format json" -filename project_field_list_15.json

    Edit-ProjectItem $owner $projectNumber $title $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $title $fieldTitle $fieldTitleValue

    $result = Get-ProjectItemsSaved -Owner $owner -ProjectNumber $projectNumber
    
    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-Contains -Expected $itemId -Presented $result.Keys
    
    Assert-Count -Expected 2 -Presented $result.$itemId
    Assert-Contains -Expected "comment" -Presented $result.$itemId.Keys
    Assert-Contains -Expected "title" -Presented $result.$itemId.Keys
    
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.comment.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.title.Value
}