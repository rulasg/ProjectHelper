function Test_NewProjectIssueDirect{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ;
    $r = $p.createIssueInRepo

    $title = "Test Issue from New-ProjectIssueDirect"
    $body = "This is a test issue created by New-ProjectIssueDirect test"
    $command = "Invoke-CreateIssue -RepositoryId $($r.id) -Title ""$title"" -Body ""$body"""

    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $p.repoFile
    MockCallJson -command $command -FileName "invoke-createissue-$($r.id).json"


     $result = New-ProjectIssueDirect -RepoOwner $r.owner -RepoName $r.name -Title "Test Issue from New-ProjectIssueDirect" -Body "This is a test issue created by New-ProjectIssueDirect test"

    # Invoke-CreateIssue -RepositoryId $result.Id -Title "Test Issue from New-ProjectIssueDirect" -Body "This is a test issue created by New-ProjectIssueDirect test" -ProjectIds @($p.id)

    # Assert
    Assert-AreEqual -Expected $r.issueUrl -Presented $result

}

test