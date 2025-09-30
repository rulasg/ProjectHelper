function Test_Edit_Sync_ProjectItem_Comments_Issue {
    
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue

    $comment = "New comment"

    MockCall_GetProject -MockProject $p -skipItems
    MockCall_GetItem  $i.id

    MockCallJson -Command "Invoke-AddIssueComment -SubjectId $($i.contentId) -Comment ""New comment""" -filename "invoke-addissuecomment-$($i.contentId).json"

    # Act the edit part
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id -FieldName "Comment" -Value $comment

    # Assert the Edit part
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected $comment -Presented $staged.$($i.id).comment.Value

    # Act the sync part
    Sync-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $staged.Count
}