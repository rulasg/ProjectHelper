function Test_NewProjectIssueDirect{

    $p = Get-Mock_Project_700
    $r = $p.repo
    $i = $p.issueToCreateAddAndRemove

    $issueTitle = "Random value title"
    $issueBody = "Random value body"
    $mockfilename = $i.createIssueMockfile

    # MockCall_GetProject $p
    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $r.getRepoMockFile
    MockCallJson -Command "Invoke-CreateIssue -RepositoryId $($r.id) -Title ""$issueTitle"" -Body ""$issueBody""" -FileName $mockfilename

    $params = @{
        RepoOwner = $r.owner
        RepoName  = $r.name
        Title     = $issueTitle
        Body      = $issueBody
    }

    $result = New-ProjectIssueDirect @params

    # Assert
    Assert-AreEqual -Expected $i.url -Presented $result

}

function Test_NewProjectIssue{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $r = $p.repo
    $i = $p.issueToCreateAddAndRemove
    $issueTitle = "Random value title"
    $issueBody = "Random value body"
    $mockfilenameCreate = "invoke-createissue-$($r.id).json"
    $mockfilenameGet = "invoke-getissueorpullrequest-$($i.number).json"

    MockCall_GetProject $p
    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $r.getRepoMockFile
    MockCallJson -Command "Invoke-CreateIssue -RepositoryId $($r.id) -Title ""$issueTitle"" -Body ""$issueBody""" -FileName $mockfilenameCreate
    MockCallJson -Command "Invoke-GetIssueOrPullRequest -Url $($i.url)" -fileName $mockfilenameGet
    MockCallJson -Command "Invoke-AddItemToProject -ProjectId $($p.id) -ContentId $($i.id)" -fileName $i.addIssueToOProjectMockFile

    # Create issue
    $params = @{
        ProjectOwner = $owner
        ProjectNumber = $projectNumber
        RepoOwner = $r.owner
        RepoName  = $r.name
        Title     = $issueTitle
        Body      = $issueBody
    }

    $result = New-ProjectIssue @params

    Assert-AreEqual -Expected $result -Presented $i.itemId
}

