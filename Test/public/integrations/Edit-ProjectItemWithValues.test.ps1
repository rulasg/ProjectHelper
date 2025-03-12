function Test_EditProjectItemWithValues_Integration{

    # Assert-SkipTest
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"

    MockCallJson -Command "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectnumber" -Filename "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.json"

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