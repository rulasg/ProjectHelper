function Test_GetProjectFields_SUCCESS_AllFields{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number
    MockCall_GetProject -MockProject $p -SkipItems

    $result = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected $p.fields.totalCount -Presented $result

    $result = $result | Sort-Object -Property Name

    foreach ($expField in $p.fields.list){
        $f = $result | Where-Object { $_.Name -eq $expField.Name }
        
        Assert-AreEqual -Presented $f.Name -Expected $expField.Name
        Assert-AreEqual -Presented $f.dataType -Expected $expField.dataType
    }

    # Body
    $f = $result | Where-Object { $_.Name -eq "Body" }
    Assert-AreEqual -Presented $f.Name -Expected "Body"
    Assert-AreEqual -Presented $f.dataType -Expected "BODY"

    # AddComment
    $f = $result | Where-Object { $_.Name -eq "AddComment" }
    Assert-AreEqual -Presented $f.Name -Expected "AddComment"
    Assert-AreEqual -Presented $f.dataType -Expected "ADDCOMMENT"

}

function Test_GetProjectFields_Fail_Comments_Present{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $p.projectFile_WrongField -SkipItems

    $hasthrow = $false
    try{
        $null = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber
    } catch {
        $hasthrow = $true
        $resultErrorMessage = $_.Exception.Message
    }
    Assert-IsTrue -Condition $hasthrow

    $errorMessage = "Set-ContentFields: [ Body ] field already exists. Please remove or rename this field from the project"
    Assert-AreEqual -Expected $errorMessage -Presented $resultErrorMessage
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