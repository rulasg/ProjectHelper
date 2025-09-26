function Test_UpdateProjectItemsBetweenProjects{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p625 = Get-Mock_Project_625 ; $owner0 = $p625.owner ; $projectNumber0 = $p625.number
    $p626 = Get-Mock_Project_626 ; $owner1 = $p626.owner ; $projectNumber1 = $p626.number

    $sourceOwner = $owner0 ; $sourceProjectNumber = $projectNumber0
    $destinationOwner = $owner1 ; $destinationProjectNumber = $projectNumber1

    MockCall_GetProject -MockProject $p625
    MockCall_GetProject -MockProject $p626

    $fieldlist = @("Int1", "Int2")

    $params = @{
        SourceOwner = $sourceOwner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $destinationOwner
        DestinationProjectNumber = $destinationProjectNumber
        FieldSlug = "pr1_"
    }
    $result = Update-ProjectItemsBetweenProjects -IncludeDoneItems     @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    $p = $p626.syncBtwPrj_625
    
    Assert-AreEqual -Expected $p.staged.Count -Presented $staged.Count
    foreach ($itemId in $staged.Keys) {
        Assert-AreEqual -Expected $p.staged.$itemId.Count -Presented $staged.$itemId.Count
        foreach ($fieldId in $p.staged.$itemId.Keys) {
            Assert-AreEqual -Expected $p.staged.$itemId.$fieldId -Presented $staged.$itemId.$fieldId.Value
        }
    }
}

function Test_UpdateProjectItemsBetweenProjects_NoRefresh_NoRefresh{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p625 = Get-Mock_Project_625 ; $owner0 = $p625.owner ; $projectNumber0 = $p625.number
    $p626 = Get-Mock_Project_626 ; $owner1 = $p626.owner ; $projectNumber1 = $p626.number

    $sourceOwner = $owner0 ; $sourceProjectNumber = $projectNumber0
    $destinationOwner = $owner1 ; $destinationProjectNumber = $projectNumber1

    MockCall_GetProject -MockProject $p625 -Cache
    MockCall_GetProject -MockProject $p626 -Cache

    # Reset mocks to fail if mocks are called again
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # Act

    $params = @{
        SourceOwner = $sourceOwner
        SourceProjectNumber = $sourceProjectNumber
        DestinationOwner = $destinationOwner
        DestinationProjectNumber = $destinationProjectNumber
        FieldSlug = "pr1_"
    }
    $result = Update-ProjectItemsBetweenProjects -IncludeDoneItems -NoRefreshDestination -NoRefreshSource @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner $destinationOwner -ProjectNumber $destinationProjectNumber

    $p = $p626.syncBtwPrj_625
    Assert-AreEqual -Expected $p.staged.Count -Presented $staged.Count

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