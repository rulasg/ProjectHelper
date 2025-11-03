function Test_GetProject_With_Query{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.projectNumber
    $i = $p.issue
    $query = "some query"
    
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -Query $query

    $result = Get-Project

    Assert-NotImplemented
    
}