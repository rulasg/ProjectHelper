function Test_UpdateProjectItemsBetweenProjects{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $sourceProjectNumber = 625
    $destinationProjectNumber = 626

    # Mock project calls
    $sourceProjectNumber, $destinationProjectNumber | ForEach-Object {
        $projectNumber = $_
        MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.syncprj.json"
    }

    $fieldlist = @("Int1", "Int2")

    $params = @{
        SourceOwner = $owner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $owner
        DestinationProjectNumber = $destinationProjectNumber
    }
    $result = Update-ProjectItemsBetweenProjects -IncludeDoneItems     @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    Assert-Count -Expected 3 -Presented $staged.Keys

    Assert-Count -Expected 2 -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpRY.Keys
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpP0.PVTF_lADOAlIw4c4A0QAozgp6aGw.Value -Expected "Value issue 1"
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpP0.PVTF_lADOAlIw4c4A0QAozgp6aK4.Value -Expected "11"

    Assert-Count -Expected 2 -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpSc.Keys
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpSc.PVTF_lADOAlIw4c4A0QAozgp6aGw.Value -Expected "Value issue 3"
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpSc.PVTF_lADOAlIw4c4A0QAozgp6aK4.Value -Expected "33"

    Assert-Count -Expected 2 -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpP0.Keys
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpRY.PVTF_lADOAlIw4c4A0QAozgp6aGw.Value -Expected "Value issue 2"
    Assert-AreEqual -Presented $staged.PVTI_lADOAlIw4c4A0QAozgYQpRY.PVTF_lADOAlIw4c4A0QAozgp6aK4.Value -Expected "22"

}

function Test_UpdateProjectItemsBetweenProjects_NoRefresh_NoRefresh{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $sourceProjectNumber = 625
    $destinationProjectNumber = 626

    # Mock project calls
    $sourceProjectNumber, $destinationProjectNumber | ForEach-Object {
        $projectNumber = $_
        MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.syncprj.json"
    }

    # Cache projects using mocks calls
    $destinationProject = Get-Project -Owner $owner -ProjectNumber $destinationProjectNumber
    $sourceProject = Get-Project -Owner $owner -ProjectNumber $sourceProjectNumber

    # Reset mocks to fail if mocks are called again
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # Act

    $params = @{
        SourceOwner = $owner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $owner
        DestinationProjectNumber = $destinationProjectNumber
    }
    $result = Update-ProjectItemsBetweenProjects -IncludeDoneItems  -NoRefreshDestination -NoRefreshSource @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    Assert-Count -Expected 3 -Presented $staged.Keys

}

function Test_SyncProjectItemsBetweenProjects_SameValues{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    MockCall_GetProject_700
    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # Setting source and destination project the same
    $sourceProjectNumber = $projectNumber
    $destinationProjectNumber = $projectNumber

    $params = @{
        SourceOwner = $owner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $owner
        DestinationProjectNumber = $destinationProjectNumber
    }

    # TODO : this call takes long on every test. Make it quicker
    $result = Update-ProjectItemsBetweenProjects @params

    Assert-IsNull -Object $result -Comment "func always should return null"

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    Assert-Count -Expected 0 -Presented $staged.Keys
}