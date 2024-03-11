function ProjectHelperTest_GetProjectFields_SUCCESS{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 

    # title refrence with differnt case and spaces
    $filter = "epic"

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields"

    $result = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 18 -Presented $result

    $result = $result | Sort-Object -Property Name

    Assert-AreEqual -Presented $result[0].Name -Expected "Assignees"           ; Assert-AreEqual -Presented $result[0].dataType -Expected "ASSIGNEES"
    Assert-AreEqual -Presented $result[1].Name -Expected "Comment"             ; Assert-AreEqual -Presented $result[1].dataType -Expected "TEXT"
    Assert-AreEqual -Presented $result[2].Name -Expected "End Date"            ; Assert-AreEqual -Presented $result[2].dataType -Expected "DATE"
    Assert-AreEqual -Presented $result[3].Name -Expected "Labels"              ; Assert-AreEqual -Presented $result[3].dataType -Expected "LABELS"
    Assert-AreEqual -Presented $result[4].Name -Expected "Linked pull requests" ; Assert-AreEqual -Presented $result[4].dataType -Expected "LINKED_PULL_REQUESTS"
    Assert-AreEqual -Presented $result[5].Name -Expected "Milestone"           ; Assert-AreEqual -Presented $result[5].dataType -Expected "MILESTONE"
    Assert-AreEqual -Presented $result[6].Name -Expected "Next Action Date"    ; Assert-AreEqual -Presented $result[6].dataType -Expected "DATE"
    Assert-AreEqual -Presented $result[7].Name -Expected "Priority"            ; Assert-AreEqual -Presented $result[7].dataType -Expected "SINGLE_SELECT"
    Assert-AreEqual -Presented $result[8].Name -Expected "Repository"          ; Assert-AreEqual -Presented $result[8].dataType -Expected "REPOSITORY"
    Assert-AreEqual -Presented $result[9].Name -Expected "Reviewers"           ; Assert-AreEqual -Presented $result[9].dataType -Expected "REVIEWERS"
    Assert-AreEqual -Presented $result[10].Name -Expected "Severity"            ; Assert-AreEqual -Presented $result[10].dataType -Expected "SINGLE_SELECT"
    Assert-AreEqual -Presented $result[11].Name -Expected "Start Date"          ; Assert-AreEqual -Presented $result[11].dataType -Expected "DATE"
    Assert-AreEqual -Presented $result[12].Name -Expected "Status"              ; Assert-AreEqual -Presented $result[12].dataType -Expected "SINGLE_SELECT"
    Assert-AreEqual -Presented $result[13].Name -Expected "TimeTracker"         ; Assert-AreEqual -Presented $result[13].dataType -Expected "NUMBER"
    Assert-AreEqual -Presented $result[14].Name -Expected "Title"               ; Assert-AreEqual -Presented $result[14].dataType -Expected "TITLE"
    Assert-AreEqual -Presented $result[15].Name -Expected "Tracked by"          ; Assert-AreEqual -Presented $result[15].dataType -Expected "TRACKED_BY"
    Assert-AreEqual -Presented $result[16].Name -Expected "Tracks"              ; Assert-AreEqual -Presented $result[16].dataType -Expected "TRACKS"
    Assert-AreEqual -Presented $result[17].Name -Expected "UserStories"         ; Assert-AreEqual -Presented $result[17].dataType -Expected "NUMBER"
}