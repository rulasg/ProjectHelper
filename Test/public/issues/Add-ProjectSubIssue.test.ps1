function Test_AddProjectSubIssue_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number


    $parent  = $p.Issue
    $i0 = $p.subIssues[0]
    $i1 = $p.subIssues[1]
    
    MockCall_GetProject $p -Cache

    MockCallJson -Command "Invoke-AddSubIssue -IssueId $($parent.contentId) -SubIssueUrl $($i0.url) -ReplaceParent False" -File "$($i0.addSubIssueMockfile)"
    MockCallJson -Command "Invoke-AddSubIssue -IssueId $($parent.contentId) -SubIssueUrl $($i1.url) -ReplaceParent False" -File "$($i1.addSubIssueMockfile)"
    

    # Act add SubIssue 1
    $params = @{
        Owner = $owner
        ProjectNumber = $projectNumber
        ItemId = $parent.Id
    }

    $result = Add-ProjectSubIssueDirect -SubIssueUrl $i0.url @params

    # Assert
    Assert-IsTrue -Condition $result

    $item = Get-ProjectItem -ItemId $parent.Id -Owner $owner -ProjectNumber $projectNumber

    Assert-AreEqual -Expected 1 -Presented $item.subIssues.Count
    Assert-Contains -Expected $i0.contentId -Presented $item.subIssues[0].id

    # Act add SubIssue 2
     $result = Add-ProjectSubIssueDirect -SubIssueUrl $i1.url @params

    # Assert
    Assert-IsTrue -Condition $result
    $item = Get-ProjectItem -ItemId $parent.Id -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected 2 -Presented $item.subIssues.Count
    Assert-Contains -Expected $i0.contentId -Presented $item.subIssues[0].id
    Assert-Contains -Expected $i1.contentId -Presented $item.subIssues[1].id
}

function Test_AddProjectSubIssue_FAIL_ALREADY_HAS_PARENT {

    Assert-NotImplemented
}

function Test_GetProjectSubIssue_SUCCESS {

    Assert-NotImplemented
}