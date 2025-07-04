function Test_UpdateProjectItemStatusOnDueDate{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString "2025-03-15"
    MockCall_GitHubOrgProjectWithFields -Owner octodemo -ProjectNumber 625 -FileName "invoke-GitHubOrgProjectWithFields-octodemo-625.updateStatus.json"

    # > prg = Get-Project -Owner octodemo -ProjectNumber 625
    # > $prj.items.values | Select id,NCC,Status | Sort-Object NCC
    #
    # id                           NCC        Status
    # --                           ---        ------
    # PVTI_lADOAlIw4c4A0Lf4zgYQpP4
    # PVTI_lADOAlIw4c4A0Lf4zgYVsJc 2025-03-09 Done
    # PVTI_lADOAlIw4c4A0Lf4zgYNTwo 2025-03-11
    # PVTI_lADOAlIw4c4A0Lf4zgYQpRc 2025-03-14
    # PVTI_lADOAlIw4c4A0Lf4zgYNTc0 2025-03-15
    # PVTI_lADOAlIw4c4A0Lf4zgYUeW4 2025-03-15
    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI 2025-03-15
    # PVTI_lADOAlIw4c4A0Lf4zgYQpSY 2025-03-16
    # PVTI_lADOAlIw4c4A0Lf4zgYNTyM 2025-03-22
    # PVTI_lADOAlIw4c4A0Lf4zgYUecs 2025-03-26
    #
    # 10 total
    # 9 with NCC
    # 6 with NCC overdued
    # 1 with Status Done


    $params = @{
        Owner = "octodemo"
        ProjectNumber = 625
        Status = "Todo"
        DueDateFieldName = "NCC"
    }

    $result = Update-ProjectItemsStatusOnDueDate @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner octodemo -ProjectNumber 625

    Assert-Count -Expected 5 -Presented $staged

    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTc0 -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTwo -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTxI -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYQpRc -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYUeW4 -Presented $staged.Keys
    Assert-NotContains -Expected PVTI_lADOAlIw4c4A0Lf4zgYVsJc -Presented $staged.Keys -Comment "Done item"
    Assert-NotContains -Expected PVTI_lADOAlIw4c4A0Lf4zgYQpP4 -Presented $staged.Keys -Comment "Item without NCC"

    # Act with NotDone
    Reset-ProjectItemStaged -Owner octodemo -ProjectNumber 625

    # Act
    $result = Update-ProjectItemsStatusOnDueDate -IncludeDoneItems @params

    # Assert
    Assert-IsNull -Object $result
    $staged = Get-ProjectItemStaged -Owner octodemo -ProjectNumber 625
    Assert-Count -Expected 6 -Presented $staged
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYVsJc -Presented $staged.Keys -Comment "Done item "

}