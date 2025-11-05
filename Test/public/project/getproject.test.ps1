function Test_GetProject_With_Query{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue
    $query = "some query"
    
    # MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -Query $query -Fieldname

    $result = Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -query $query

    $result = Update-ProjectDatabase -Owner $owner -ProjectNumber $projectNumber -Query $query

    Assert-NotImplemented
    
}