function Test_GetProjectFields_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -SkipItems

    $result = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 19 -Presented $result

    $result = $result | Sort-Object -Property Name

    function AssertField($index, $expectedName, $expectedDataType, $expectedType){
        Assert-AreEqual -Presented $result[$index].Name -Expected $expectedName
        Assert-AreEqual -Presented $result[$index].dataType -Expected $expectedDataType
    }

    AssertField -Index 0 -ExpectedName "Assignees"            -ExpectedDataType "ASSIGNEES"
    AssertField -Index 1 -ExpectedName "Body"                -ExpectedDataType "BODY"
    AssertField -Index 2 -ExpectedName "Comment"              -ExpectedDataType "TEXT"
    AssertField -Index 3 -ExpectedName "End Date"             -ExpectedDataType "DATE"
    AssertField -Index 4 -ExpectedName "Labels"               -ExpectedDataType "LABELS"
    AssertField -Index 5 -ExpectedName "Linked pull requests" -ExpectedDataType "LINKED_PULL_REQUESTS"
    AssertField -Index 6 -ExpectedName "Milestone"            -ExpectedDataType "MILESTONE"
    AssertField -Index 7 -ExpectedName "Next Action Date"     -ExpectedDataType "DATE"
    AssertField -Index 8 -ExpectedName "Priority"             -ExpectedDataType "SINGLE_SELECT"
    AssertField -Index 9 -ExpectedName "Repository"           -ExpectedDataType "REPOSITORY"
    AssertField -Index 10 -ExpectedName "Reviewers"            -ExpectedDataType "REVIEWERS"
    AssertField -Index 11 -ExpectedName "Severity"            -ExpectedDataType "SINGLE_SELECT"
    AssertField -Index 12 -ExpectedName "Start Date"          -ExpectedDataType "DATE"
    AssertField -Index 13 -ExpectedName "Status"              -ExpectedDataType "SINGLE_SELECT"
    AssertField -Index 14 -ExpectedName "TimeTracker"         -ExpectedDataType "NUMBER"
    AssertField -Index 15 -ExpectedName "Title"               -ExpectedDataType "TITLE"
    AssertField -Index 16 -ExpectedName "Tracked by"          -ExpectedDataType "TRACKED_BY"
    AssertField -Index 17 -ExpectedName "Tracks"              -ExpectedDataType "TRACKS"
    AssertField -Index 18 -ExpectedName "UserStories"         -ExpectedDataType "NUMBER"
}

function Test_GetProjectFields_SUCCESS_FilterByName{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # title refrence with differnt case and spaces
    $filter = "Title"

        MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -SkipItems

    $result = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber -Name $filter

    Assert-Count -Expected 1 -Presented $result

    Assert-AreEqual -Presented $result[0].Name -Expected "Title" ; Assert-AreEqual -Presented $result[0].dataType -Expected "TITLE"
}

function Test_GetProjectFields_SUCCESS_MoreInfo{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $Owner = "SomeOrg" ; $ProjectNumber = 164

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -SkipItems

    $result = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber -Name "Status"

    Assert-Count -Expected 1 -Presented $result

    Assert-AreEqual -Presented $result[0].Name -Expected "Status" ; Assert-AreEqual -Presented $result[0].dataType -Expected "SINGLE_SELECT"
    Assert-Count -Expected 3 -Presented $result[0].MoreInfo
    Assert-Contains -Presented $result[0].MoreInfo -Expected "Todo"
    Assert-Contains -Presented $result[0].MoreInfo -Expected "In Progress"
    Assert-Contains -Presented $result[0].MoreInfo -Expected "Done"
}