function ProjectHelperTest_GetProjetItems_SUCCESS{

    Reset-InvokeCommandMock

    $Owner = "someOwner" ; $ProjectNumber = 666 ; $itemsCount = 12

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

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
    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected $itemsCount -Presented $result

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