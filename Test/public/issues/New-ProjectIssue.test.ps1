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

function Test_CopyProjectIssue_SUCCESS {

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $r = $p.repo
    $i = $p.issueToCreateAddAndRemove
    $sourceItemId = $p.issue.id

    MockCall_GetProject $p -cache

    $createString = 'Invoke-CreateIssue -RepositoryId {repoid} -Title "{title}" -Body "{body}"'
    $createString = $createString -replace "{repoid}", $r.id
    $createString = $createString -replace "{title}", $i.title
    $createString = $createString -replace "{body}", $i.body

    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $r.getRepoMockFile
    MockCallToObject -Command $createString -OutObject @{ data = @{ createIssue = @{ issue = @{ url = $i.url } } } }
    MockCallJson -Command "Invoke-GetIssueOrPullRequest -Url $($i.url)" -FileName $i.getIssueOrPullRequestMockFile
    MockCallJson -Command "Invoke-AddItemToProject -ProjectId $($p.id) -ContentId $($i.id)" -FileName $i.addIssueToOProjectMockFile

    # Act
    $result = Copy-ProjectIssue -ItemId $sourceItemId -ProjectOwner $owner -ProjectNumber $projectNumber -RepoOwner $r.owner -RepoName $r.name

    # Assert
    Assert-AreEqual -Expected $i.itemId -Presented $result
}

function Test_CopyProjectIssue_SUCCESS_DoNotAddToProject {

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $r = $p.repo
    $i = $p.issueToCreateAddAndRemove
    $sourceItemId = $p.issue.id

    MockCall_GetProject $p -cache

    $createString = 'Invoke-CreateIssue -RepositoryId {repoid} -Title "{title}" -Body "{body}"'
    $createString = $createString -replace "{repoid}", $r.id
    $createString = $createString -replace "{title}", $i.title
    $createString = $createString -replace "{body}", $i.body

    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $r.getRepoMockFile
    MockCallToObject -Command $createString -OutObject @{ data = @{ createIssue = @{ issue = @{ url = $i.url } } } }

    # Act
    $result = Copy-ProjectIssue -ItemId $sourceItemId -ProjectOwner $owner -ProjectNumber $projectNumber -RepoOwner $r.owner -RepoName $r.name -DoNotAddToProject

    # Assert
    Assert-AreEqual -Expected $sourceItemId -Presented $result

}
