function Test_RemoveProjectIssue_SUCCESS {

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issueToCreateAddAndRemove

    MockCall_GetProject $p

    # Add item to project to remover it later
    MockCallJson -Command "Invoke-GetIssueOrPullRequest -Url $($i.url)" -fileName $i.getIssueOrPullRequestMockFile
    MockCallJson -Command "Invoke-AddItemToProject -ProjectId $($p.id) -ContentId $($i.id)" -fileName $i.addIssueToOProjectMockFile
    $itemId = Add-ProjectItem -owner $owner -projectNumber $projectNumber -Url $i.url
    $item = Get-ProjectItem -Id $itemId
    Assert-AreEqual -expected $i.id -Presented $item.contentId

    MockCallJson -Command "Invoke-RemoveItemFromProject -ProjectId $($p.id) -ItemId $($i.itemId)" -fileName $i.removeIssueFromProjectMockFile

    # Act
    $result = Remove-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId

    # Assert
    Assert-AreEqual -Expected $i.url -Presented $result
    Assert-IsFalse -Condition $(Test-ProjectItem -Url $i.url)

    # Remove issue assocaited
    $itemId = Add-ProjectItem -owner $owner -projectNumber $projectNumber -Url $i.url
    Assert-IsTrue -Condition $(Test-ProjectItem -Url $i.url)
    MockCallJson -Command "Invoke-RemoveIssue -IssueId $($i.id)" -FileName "invoke-removeissue-any.json"

    # Act
    $result = Remove-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -DeleteIssue

    # Assert
    Assert-IsTrue -Condition $result

}