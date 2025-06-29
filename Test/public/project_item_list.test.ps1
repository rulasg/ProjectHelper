function Test_GetProjetItemList_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result

    $randomItem = $result.PVTI_lADOBCrGTM4ActQazgMuXXc

    # Item 10 - Chose one at random
    Assert-AreEqual -Presented $randomItem.UserStories  -Expected "8"
    Assert-AreEqual -Presented $randomItem.body         -Expected "some content in body"
    Assert-AreEqual -Presented $randomItem.Comment      -Expected "This"
    Assert-AreEqual -Presented $randomItem.Title        -Expected "A draft in the project"
    Assert-AreEqual -Presented $randomItem.state        -Expected "CLOSED"
    Assert-AreEqual -Presented $randomItem.id           -Expected "PVTI_lADOBCrGTM4ActQazgMuXXc"
    Assert-AreEqual -Presented $randomItem.type         -Expected "DraftIssue"
    Assert-AreEqual -Presented $randomItem.TimeTracker  -Expected "890"
    Assert-AreEqual -Presented $randomItem.Severity     -Expected "Nice⭐️"
    Assert-AreEqual -Presented $randomItem.Status       -Expected "Todo"
    Assert-AreEqual -Presented $randomItem.Priority     -Expected "🥵High"
    Assert-AreEqual -Presented $randomItem.Assignees    -Expected "rulasg"

    # Reset all mock invokes
    Reset-InvokeCommandMock
    # Reset Database Mock calls. Keep database content
    Mock_DatabaseRoot -NotReset

    # Can call without mock because it will use the database information
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result
}

function Test_GetProjetItemList_FAIL{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12

    MockCall_GitHubOrgProjectWithFields_Null  -Owner $owner -ProjectNumber $projectNumber

    Mock_DatabaseRoot

    # Start the transcript

    # Run the command
    Start-MyTranscript
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber
    $tt = Stop-MyTranscript

    # Capture the standard output
    $erroMessage1= "Error: Project not found. Check owner and projectnumber"

    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage1 -Presented $tt
}

function Test_ProjectItemList_ExcludeDone{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $itemsDone = 3
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-AreEqual -Expected $itemsCount -Presented $result.Keys.Count

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -ExcludeDone

    Assert-AreEqual -Expected ($itemsCount - $itemsDone) -Presented $result.Keys.Count
}

function Test_FindProjectItemByTitle_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ; $id = "PVTI_lADOBCrGTM4ActQazgMtRO0"

    # title refrence with differnt case and spaces
    $title = "epic 1"
    $actual = "EPIC 1 "

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Find-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title

    Assert-AreEqual -Expected $id -Presented $result.id
    Assert-AreEqual -Expected $actual -Presented $result.Title
}

function Test_FindProjectItemByTitle_SUCCESS_MultipleResults{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ;
    $id1 = "PVTI_lADNJr_OALnx2s4Fqq8P"
    $id2 = "PVTI_lADOBCrGTM4ActQazgMtRPA"

    # title refrence with differnt case and spaces
    $title = "issue name 1"
    $title1 = "Issue Name 1"
    $title2 = "ISSUE NAME 1"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Find-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title -Force

    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Expected $id1 -Presented $result.id
    Assert-Contains -Expected $id2 -Presented $result.id
    Assert-AreEqual -Expected $title1 -Presented $result[0].Title
    Assert-AreEqual -Expected $title2 -Presented $result[1].Title
}

function Test_FindProjectItemByTitle_FAIL{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    MockCall_GitHubOrgProjectWithFields_Null  -Owner $owner -ProjectNumber $projectNumber

    # Run the command
    Start-MyTranscript
    $result = Find-ProjectItemByTitle -Owner $Owner -ProjectNumber $ProjectNumber
    $tt = Stop-MyTranscript

    # Capture the standard output
    $erroMessage1= "Error: Project not found. Check owner and projectnumber"

    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage1 -Presented $tt
}

function Test_SearchProjectItemByTitle_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ; $id = "PVTI_lADOBCrGTM4ActQazgMtRO0"

    # title refrence with differnt case and spaces
    $title = "epic"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Search-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title

    Assert-Count -Expected 2 -Presented $result

    Assert-Contains -Expected "EPIC 1 " -Presented $result.Title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRO0" -Presented $result.id
    Assert-Contains -Expected "EPIC 2"  -Presented $result.Title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRPg" -Presented $result.id

}


function Test_SearchProjectItemByTitle_FAIL{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    $erroMessage= "Error: Project not found. Check owner and projectnumber"

    Mock_DatabaseRoot

    MockCall_GitHubOrgProjectWithFields_Null  -Owner $owner -ProjectNumber $projectNumber

    # Run the command
    Start-MyTranscript
    $result = Search-ProjectItemByTitle -Owner $Owner -ProjectNumber $ProjectNumber
    $tt = Stop-MyTranscript

    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage -Presented $tt
}

function Test_SearchProjectItem_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # title refrence with differnt case and spaces
    $filter = "epic"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter $filter -Fields ("id","title","url","id")

    Assert-Count -Expected 2 -Presented $result

    Assert-Contains -Expected "EPIC 1 " -Presented $result.title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRO0" -Presented $result.id
    Assert-Contains -Expected "EPIC 2"  -Presented $result.title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRPg" -Presented $result.id


    $result = Search-ProjectItem 684
    Assert-AreEqual -Expected "Issue 455d29e3" -Presented $result[0].title
    Assert-AreEqual -Expected "PVTI_lADNJr_OALnx2s4Fqq8p" -Presented $result[0].id
    Assert-AreEqual -Expected "https://github.com/SomeOrg/ProjectDemoTest-repo-front/issues/3" -Presented $result[0].url

}
