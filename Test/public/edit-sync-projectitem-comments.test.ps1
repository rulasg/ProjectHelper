function Test_Edit_Sync_ProjectItem_AddComments_Issue {
    
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue

    $comment = "New comment"

    MockCall_GetProject -MockProject $p -skipItems
    MockCall_GetItem  $i.id

    MockCallJson -Command "Invoke-AddComment -SubjectId $($i.contentId) -Comment ""New comment""" -filename "invoke-addcomment-$($i.contentId).json"

    # Act the edit part
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id -FieldName "AddComment" -Value $comment

    # Assert the Edit part
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected $comment -Presented $staged.$($i.id).addcomment.Value

    # Act the sync part
    Sync-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $staged.Count
}