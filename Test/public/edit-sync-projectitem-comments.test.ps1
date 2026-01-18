function Test_Edit_Sync_ProjectItem_AddComments_Issue {

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue

    $comment = "New comment"    
    $comment2 = "Another comment2"


    MockCall_GetProject -MockProject $p -SkipItems
    MockCall_GetItem $i.id

    MockCallJson -Command "Invoke-AddComment -SubjectId $($i.contentId) -Comment ""New comment""" -filename "invoke-addcomment-$($i.contentId).json"
    MockCallJson -Command "Invoke-AddComment -SubjectId $($i.contentId) -Comment ""Another comment2""" -filename "invoke-addcomment-$($i.contentId).json"

    # Check the status of comments
    # $i = Get-projectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id


    # Act the edit part
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id -FieldName "AddComment" -Value $comment
    
    # Assert the Edit part
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected $comment -Presented $staged.$($i.id).addcomment.Value

    # Confirm that staged values are merged on GetItem
    $item = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id
    Assert-AreEqual -Expected $comment -Presented $item.comments[-1].body
    Assert-AreEqual -Expected $comment -Presented $item.commentLast.body

    # Act the sync part
    Sync-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $staged.Count

    # Assert comment is commited to database
    $item = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id
    Assert-AreEqual -Expected $comment -Presented $item.comments[-1].body
    Assert-AreEqual -Expected $comment -Presented $item.commentLast.body

    # Act more comments on a item with already has comments
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id -FieldName "AddComment" -Value $comment2

    $item = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id

    Sync-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $staged.Count
    $item = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $i.id
    Assert-AreEqual -Expected $comment2 -Presented $item.comments[-1].body
    Assert-AreEqual -Expected $comment2 -Presented $item.commentLast.body
}