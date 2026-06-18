function Test_Stub_GetProjectItem{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number
    MockCall_GetProject $p -SkipItems -Cache
    $i = $p.issue ; $itemId = $i.id

    $module = Get-ModuleRootPath | join-path -ChildPath "Test"
    
    $name = "Stub_GetProjectItem"

    # Mock Proejct readme
    Update-Mock_Project_ReadMe_With_String_And_Config -p $p -module $module

    # Use object and not hashtable to control the order of the parameters for the mock
    # The order of the parameters is important for the mock to match the expected string
    $parameters = [PSCustomObject]@{
        ItemId = $itemId
        Owner = $Owner
        ProjectNumber = [string] $ProjectNumber
    } 

    Mock_InvokeStubCommandCall $name $module $parameters $true

    # Act
    $result = Stub_GetProjectItem -ItemId $itemId -Owner $owner -ProjectNumber $projectNumber

    Assert-IsTrue -Condition $result
}

function Test_Stub_GPI_SalesHelper{

    Assert-SkipTest

    Enable-InvokeCommandAliasModule

    $result = gpi PVTI_lADNJr_OADU3Ys4Gb4om -Owner github -ProjectNumber 9279

    # Fields added from SalesHelper Get-SalesProjectItem function
    Assert-IsNotNull -Object $result.due
    Assert-IsNotNull -Object $result.NZPSG

}

function Test_Stub_GPI_ProjectHelper{

    Assert-SkipTest

    Enable-InvokeCommandAliasModule

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number
    $i = $p.issue ; $itemId = $i.id

    #kkHelper does not exist so it will default to ProjectHelper module
    $result = gpi PVTI_lADOAlIw4c4BCe3Vzgeio4o -Owner octodemo -ProjectNumber 700

    Assert-IsNotNull -Object $result

    Assert-AreEqual -Expected $owner -Present $result.projectOwner
    Assert-AreEqual -Expected $projectNumber -Present $result.projectNumber
    Assert-AreEqual -Expected $itemId -Present $result.id

}

