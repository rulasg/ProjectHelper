function ProjectHelperTest_GetProjetItems_SUCCESS{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result

    # Item 10 - Chose one at random
    Assert-AreEqual -Presented $result[10].UserStories  -Expected "8"
    Assert-AreEqual -Presented $result[10].body         -Expected "some content in body"
    Assert-AreEqual -Presented $result[10].Comment      -Expected "This"
    Assert-AreEqual -Presented $result[10].title        -Expected "A draft in the project"
    Assert-AreEqual -Presented $result[10].id           -Expected "PVTI_lADOBCrGTM4ActQazgMuXXc"
    Assert-AreEqual -Presented $result[10].type         -Expected "DraftIssue"
    Assert-AreEqual -Presented $result[10].TimeTracker  -Expected "890"
    Assert-AreEqual -Presented $result[10].Severity     -Expected "Nice⭐️"
    Assert-AreEqual -Presented $result[10].Status       -Expected "Todo"
    Assert-AreEqual -Presented $result[10].Priority     -Expected "🥵High"
    Assert-AreEqual -Presented $result[10].Assignees    -Expected "rulasg"

    Reset-InvokeCommandMock

    # Can call without mock because it will use the database information
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result
}

function ProjectHelperTest_GetProjetItems_FAIL{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12

    MockCallToNull -Command GitHubOrgProjectWithFields

    Initialize-DatabaseRoot

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

function ProjectHelperTest_FindProjectItemByTitle_SUCCESS{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ; $id = "PVTI_lADOBCrGTM4ActQazgMtRO0"

    # title refrence with differnt case and spaces
    $title = "epic 1"
    $actual = "EPIC 1 "

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Find-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title

    Assert-AreEqual -Expected $id -Presented $result.Id
    Assert-AreEqual -Expected $actual -Presented $result.Title
}

function ProjectHelperTest_FindProjectItemByTitle_SUCCESS_MultipleResults{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ; 
    $id1 = "PVTI_lADOBCrGTM4ActQazgMtROk"
    $id2 = "PVTI_lADOBCrGTM4ActQazgMtRPA"

    # title refrence with differnt case and spaces
    $title = "issue name 1"
    $title1 = "Issue Name 1"
    $title2 = "ISSUE NAME 1"

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Find-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title -Force

    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Expected $id1 -Presented $result.Id
    Assert-Contains -Expected $id2 -Presented $result.Id
    Assert-AreEqual -Expected $title1 -Presented $result[0].Title
    Assert-AreEqual -Expected $title2 -Presented $result[1].Title
}

function ProjectHelperTest_FindProjectItemByTitle_FAIL{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 

    MockCallToNull -Command GitHubOrgProjectWithFields

    # Run the command
    Start-MyTranscript
    $result = Find-ProjectItemByTitle -Owner $Owner -ProjectNumber $ProjectNumber
    $tt = Stop-MyTranscript
    
    # Capture the standard output
    $erroMessage1= "Error: Project not found. Check owner and projectnumber"

    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage1 -Presented $tt
}

function ProjectHelperTest_SearchProjectItemByTitle_SUCCESS{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164  ; $id = "PVTI_lADOBCrGTM4ActQazgMtRO0"

    # title refrence with differnt case and spaces
    $title = "epic"

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Search-ProjectItemByTitle -Owner $owner -ProjectNumber $projectNumber -Title $title

    Assert-Count -Expected 2 -Presented $result

    Assert-Contains -Expected "EPIC 1 " -Presented $result.title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRO0" -Presented $result.id
    Assert-Contains -Expected "EPIC 2"  -Presented $result.title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRPg" -Presented $result.id

}


function ProjectHelperTest_SearchProjectItemByTitle_FAIL{

    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 
    $erroMessage= "Error: Project not found. Check owner and projectnumber"

    Initialize-DatabaseRoot

    MockCallToNull -Command GitHubOrgProjectWithFields

    # Run the command
    Start-MyTranscript
    $result = Search-ProjectItemByTitle -Owner $Owner -ProjectNumber $ProjectNumber
    $tt = Stop-MyTranscript
    
    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage -Presented $tt
}

#####################
<#
    .SYNOPSIS
    Mocks the call to GitHubOrgProjectWithFields
    .DESCRIPTION
    This function is used to mock the call to GitHubOrgProjectWithFields
    Inovke helper when commanded for GitHubOrgProjectWithFields will call back this function to retrn the fake data
    This is needed as Invoke-RestMethod returns objects and the parametrs ar too long to specify on a Set-InvokeCommandAlias
#>
function MockCall_GitHubOrgProjectWithFields{
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Project
    )

    $fileName = $MOCK_PATH | Join-Path -ChildPath 'orgprojectwithfields.json'
    $content = Get-Content -Path $fileName | Out-String | ConvertFrom-Json

    return $content
} Export-ModuleMember -Function MockCall_GitHubOrgProjectWithFields