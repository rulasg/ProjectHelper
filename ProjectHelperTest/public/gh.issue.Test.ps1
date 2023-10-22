function ProjectHelperTest_GHI_NewGHIssue_Simple{
    # Need to inject gh call for testing

    $title = "[DevTraining] Session 6"
    $body = "This is the body"
    $repoOwner = "someOwner"; $repoName = "someRepo" ; $repo = "$repoOwner/$repoName"

    # $expressionPattern = 'gh issue create --repo "{0}" --title "{1}" --body "{2}"'
    # $command = $expressionPattern -f $Repo,$Title,$Body

    Set-MockCommand -CommandName 'Issue_Create'

    $result = New-Issue -Repo $repo -Title $title -Body $body  @InfoParameters 

    Assert-AreEqual -Presented $result -Expected "https://github.com/rulasg/testPublicRepo/issues/4"
}

function ProjectHelperTest_GHI_GetGHIssue_Simple{

    # Set-MockCommand -CommandName 'Issue_List' -FileName 'issue_list.json'
    Set-MockCommand -CommandName 'Issue_List' 

    $repo = "rulasg/testPublicRepo"

    $result = Get-Issues -Repo $repo @InfoParameters

    Assert-IsNotNull -Object $result
    Assert-Count -Expected 3 -Presented $result
    Assert-AreEqual -Expected 'https://github.com/rulasg/testPublicRepo/issues' -Presented ($result[0].url | Split-Path -Parent)
}
