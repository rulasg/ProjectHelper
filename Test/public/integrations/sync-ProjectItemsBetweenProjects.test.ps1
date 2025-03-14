function Test_SyncProjectItemsBetweenProjects{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    Mock_GetProject_Octodemop_625_626_Sync

    
    $owner = "octodemo"
    $sourceProjectNumber = 625
    $destinationProjectNumber = 626
    
    $fieldlist = @("Int1", "Int2")

    $params = @{
        SourceOwner = $owner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $owner
        DestinationProjectNumber = $destinationProjectNumber
        FieldsList = $fieldlist
    }
    $result = Sync-ProjectItemsBetweenProjects @params

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

function Test_SyncProjectItemsBetweenProjects_SameValues{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    Mock_GetProject_Octodemop_625_626_Sync

    $owner = "octodemo"
    $sourceProjectNumber = 625
    $destinationProjectNumber = 625

    $fieldlist = @("Int1", "Int2")

    $params = @{
        SourceOwner = $owner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $owner
        DestinationProjectNumber = $destinationProjectNumber
        FieldsList = $fieldlist
    }
    $result = Sync-ProjectItemsBetweenProjects @params

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    Assert-Count -Expected 0 -Presented $staged.Keys
}