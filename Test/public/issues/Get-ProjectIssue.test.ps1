function Test_GetProjectIssue{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue

    MockCallJson -Command "Invoke-GetIssueOrPullRequest -Url $($i.url)" -FileName "invoke-GetIssueOrPullRequest-26.json"

    # Act
    $result = Get-ProjectIssue -Url $i.url

    Assert-AreEqual -Expected $i.contentId -Presented $result.id
    Assert-AreEqual -Expected $i.title -Presented $result.title
    Assert-AreEqual -Expected $i.url -Presented $result.url

}