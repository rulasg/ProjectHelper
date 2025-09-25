function Test_GetProjetItemList_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue
    $itemsCount = $p.items.totalCount

    MockCall_GetProject_700

    # Act
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result

    $randomItem = $result.$($i.Id)

    Assert-AreEqual -Presented $randomItem.Title        -Expected "Issue for development"
    Assert-AreEqual -Presented $randomItem.body         -Expected "Body of issue for development" 
    Assert-AreEqual -Presented $randomItem.state        -Expected "OPEN"
    Assert-AreEqual -Presented $randomItem.id           -Expected "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    Assert-AreEqual -Presented $randomItem.type         -Expected "Issue"
    Assert-AreEqual -Presented $randomItem.Status       -Expected "Todo"
    Assert-AreEqual -Presented $randomItem.Milestone    -Expected "Milestone 3: Quality and Deployment"
    Assert-AreEqual -Presented $randomItem.Repository   -Expected "https://github.com/octodemo/rulasg-dev-1"
    Assert-AreEqual -Presented $randomItem."field-text"   -Expected "text3"
    Assert-AreEqual -Presented $randomItem."field-number" -Expected "333"
    Assert-AreEqual -Presented $randomItem."field-singleselect" -Expected "option-3"
    Assert-AreEqual -Presented $randomItem.databaseId   -Expected "128099210"
    Assert-AreEqual -Presented $randomItem.projectUrl   -Expected "https://github.com/orgs/octodemo/projects/700"
    # Assert-AreEqual -Presented $randomItem.updatedAt    -Expected "9/11/2025 1:06:24 PM"
    Assert-AreEqual -Presented $randomItem.number       -Expected "26"
    Assert-AreEqual -Presented $randomItem.contentId    -Expected "I_kwDOPrRnkc7KkwSq"
    Assert-AreEqual -Presented $randomItem.projectId    -Expected "PVT_kwDOAlIw4c4BCe3V"
    Assert-AreEqual -Presented $randomItem.urlContent   -Expected "https://github.com/octodemo/rulasg-dev-1/issues/26"
    Assert-AreEqual -Presented $randomItem.urlPanel     -Expected "https://github.com/orgs/octodemo/projects/700/views/1?pane=issue&itemId=128099210"
    Assert-AreEqual -Presented $randomItem.url          -Expected "https://github.com/octodemo/rulasg-dev-1/issues/26"
    # Assert-AreEqual -Presented $randomItem.createdAt    -Expected "9/9/2025 2:01:17 PM"
    # Assert-AreEqual -Presented $randomItem."field-iteration" -Expected ""

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

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue
    $itemsCount = $p.items.totalCount
    $itemsDone = $p.items.doneCount

    MockCall_GetProject_700

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-AreEqual -Expected $itemsCount -Presented $result.Keys.Count

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -ExcludeDone

    Assert-AreEqual -Expected ($itemsCount - $itemsDone) -Presented $result.Keys.Count
}

function Test_SearchProjectItemByTitle_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # title refrence with differnt case and spaces
    $title = $p.searchInTitle.titleFilter

    # Act
    $result = Search-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title

    Assert-Count -Expected $p.searchInTitle.totalCount -Presented $result

    $p.searchInTitle.Titles | ForEach-Object {
        Assert-Contains -Expected $_ -Presented $result.Title
    }

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
