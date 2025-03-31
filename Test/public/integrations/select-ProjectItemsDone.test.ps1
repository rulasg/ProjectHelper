function Test_SelectProjectItemNotDone{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    . $(Get-Ps1FullPath -FolderName Public -Name "integrations/select-ProjectItemsDone.ps1")

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    $IncludeDoneItemsItems = $prj.items.values | Where-Object { $_.Status -ne "Done" }
    Assert-Count -Expected 12 -Presented $prj.items.values
    Assert-Count -Expected 9 -Presented $IncludeDoneItemsItems

    # Act
    $result = $prj.items | Select-ProjectItemsNotDone

    $IncludeDoneItemsItems.id | ForEach-Object {
        Assert-Contains -Expected $_ -Presented $result.Keys
    }
}