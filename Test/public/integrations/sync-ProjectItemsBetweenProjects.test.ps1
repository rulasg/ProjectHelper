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

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $destinationProjectNumber

    Assert-NotImplemented
}