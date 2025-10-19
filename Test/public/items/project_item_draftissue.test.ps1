function Test_NewProjectDraftIssue {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    MockCall_GetProject -MockProject $p

    $title = "DraftIssue created for test "
    $body = "Body of draftissue"

    MockCallJson -Command "Invoke-CreateDraftItem -ProjectId $($p.id) -Title ""$title"" -Body ""$body""" -FileName "invoke-createDraftItem.json"

    # Act
    $draftIssueId = New-ProjectDraftIssue -Owner $owner -ProjectNumber $projectNumber -Title $title -Body $body


    $item = Get-ProjectItem -ItemId $draftIssueId

    # Assert
    Assert-AreEqual -Expected $draftIssueId -Presented $item.id
    Assert-AreEqual -Expected $title -Presented $item.Title
    Assert-AreEqual -Expected $body -Presented $item.Body

}