function Test_EditProjectItemWithValues_Integration{

    # Assert-SkipTest
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$Owner-$ProjectNumber.2.json" 

    $data = @{
        "Text1" = "value1"
        "Text2" = "value2"
        "Text3" = "value3"
        "Number1" = "value3"
    }

    $result = Edit-ProjectItemWithValues -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Values $data -FieldSlug $FieldSlug

    # Assert - Confirm update
    # Assert-IsNull -Object $result

    $result = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId

    Assert-AreEqual -expected $data.Text1 -Presented $result.$($FieldSlug + "Text1")
    Assert-AreEqual -expected $data.Text2 -Presented $result.$($FieldSlug + "Text2")
    # Assert-AreEqual -expected $data.Text3 -Presented $result.$($FieldSlug + "Text3") 
    Assert-AreEqual -expected $data.Number1 -Presented $result.$($FieldSlug + "Number1")

    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 3 -Presented $result.$itemId

}


function Test_UpdateProjectWithIntegration{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # https://github.com/orgs/octodemo/projects/625/views/1

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"
    $IntegrationField = "sfUrl"
    $IntegrationCommand = "Get-SfAccount"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$Owner-$ProjectNumber.2.json" 

    $data1 = @{
        "Text1" = "value11"
        "Text2" = "value12"
        "Text3" = "value13"
        "Number1" = 11
    }

    $data2 = @{
        "Text1" = "value21"
        "Text2" = "value22"
        "Text3" = "value23"
        "Number1" = 22
    }

    MockCallToObject -Command "Get-SfAccount https://some.com/1234/viuew" -OutObject $data1
    MockCallToObject -Command "Get-SfAccount https://some.com/4321/viuew" -OutObject $data2

    $param = @{
        Owner = $owner
        ProjectNumber = $projectNumber
        IntegrationField = $IntegrationField
        IntegrationCommand = $IntegrationCommand
        Slug = $fieldSlug
    }

   $result = Update-ProjectItemsWithIntegration @param


    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 2 -Presented $result

    # PVTI_lADOAlIw4c4A0Lf4zgYNTc0
    Assert-AreEqual -Expected $($data1.Text1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value
    Assert-AreEqual -Expected $($data1.Text2) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value
    Assert-AreEqual -Expected $($data1.Number1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2mBs.Value
    
    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI
    Assert-AreEqual -Expected $($data2.Text1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value
    Assert-AreEqual -Expected $($data2.Text2) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value
    Assert-AreEqual -Expected $($data2.Number1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2mBs.Value
}