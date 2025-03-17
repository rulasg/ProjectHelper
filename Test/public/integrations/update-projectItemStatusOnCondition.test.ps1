function Test_UpdateProjectItemStatusOnDueDate{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GitHubOrgProjectWithFields -Owner octodemo -ProjectNumber 625 -FileName "invoke-GitHubOrgProjectWithFields-octodemo-625.updateStatus.json"
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString "2025-03-15"

    $params = @{
        Owner = "octodemo"
        ProjectNumber = 625
        Status = "ActionRequired"
        DueDateFieldName = "NCC"
    }

    $result = Update-ProjectItemStatusOnDueDate @params

    Assert-IsNull -Object $result

    $staged = Get-ProjectItemStaged -Owner octodemo -ProjectNumber 625

    Assert-Count -Expected 5 -Presented $staged

    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTc0 -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTwo -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYNTxI -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYQpRc -Presented $staged.Keys
    Assert-Contains -Expected PVTI_lADOAlIw4c4A0Lf4zgYUeW4 -Presented $staged.Keys

}