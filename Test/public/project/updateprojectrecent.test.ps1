function Test_UpdateProject_SetsRecentUpdateToday_WhenQueryIsNull{
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $today = (Get-Mock_Today).today

    MockCall_GetProject $p

    # Act
    $result = Update-Project -Owner $owner -ProjectNumber $projectNumber

    # Assert
    Assert-IsTrue $result

    # Verify Set-EnvItem_Last_RecentUpdate_Today was called - check the env item is set to today
    $envValue = Invoke-PrivateContext { Get-EnvItem_Last_RecentUpdate -Owner "octodemo" -ProjectNumber 700 }

    Assert-AreEqual -Expected $today -Presented $envValue -Comment "Set-EnvItem_Last_RecentUpdate_Today should set env item to today when Query is null"
}

function Test_UpdateProjectRecent_FirstCAll_SetRecentUpdate_toToday{
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    Mock_Today

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $today = (Get-Mock_Today).today

    # Mock full sync to be called by Update-ProjectRecent first time
    MockCall_GetProject_700

    # Act first call will sync full with query to null
    $result = Update-ProjectRecent -Owner $owner -ProjectNumber $projectNumber

    # Assert
    Assert-IsTrue $result

    # Verify Set-EnvItem_Last_RecentUpdate_Today was NOT called - env item should be null/empty
    $envValue = Invoke-PrivateContext { Get-EnvItem_Last_RecentUpdate -Owner "octodemo" -ProjectNumber 700 }
    Assert-IsNotNull -Object $envValue
    Assert-AreEqual -Expected $today -Presented $envValue

}

function Test_UpdateProjectRecent_UpdateBasedOn_SetRecentUpdate{
    # Arrange
    
    Reset-InvokeCommandMock
    $today = (Get-Mock_Today).today
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString $today
    
    # Cache project
    Mock_DatabaseRoot
    MockCall_GetProject_700 -Cache
    
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString $today

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $query  = "updated:<$today"
    # not real query just a mock file with some items reply
    $fileName = $p.getProjectWithQuery.getProjectWithQueryMockFile

    # Set te only sync allowed on Update-ProjectRecent
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -Query $query -FileName $fileName

    # Act second time - call Update-ProjectRecent again to ensure it uses the last recent update date
    $result = Update-ProjectRecent -Owner $owner -ProjectNumber $projectNumber
    Assert-IsTrue $result
}
