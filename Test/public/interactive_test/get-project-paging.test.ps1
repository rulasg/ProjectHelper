function Test_GetProject_Paging_SUCCESS{

    Assert-SkipTest
    
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $owner = "github"; $projectNumber = 9279

    $result = Get-Project -Owner $owner -ProjectNumber $projectNumber -Force

    Assert-NotNull -Presented $result

    $presented = Get-ProjectItemList -Owner $owner -ProjectNumber $projectNumber
    $fields = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 332 -Presented $presented
    Assert-Count -Expected 24 -Presented $fields
}

function Test_GetProject_SUCCESS{

    Assert-SkipTest

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $owner = "github"; $projectNumber = 9279

    $result = Get-Project -Owner $owner -ProjectNumber $projectNumber -Force

    Assert-NotNull -Presented $result

    Assert-NotImplemented
}