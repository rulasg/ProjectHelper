function Test_EditProjectItemWithValues_Integration {

    # Assert-SkipTest

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$Owner-$ProjectNumber.2-skipitems.json" -SkipItems

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    $data = @{
        "Text1"   = "value1"
        "Text2"   = "value2"
        "Text3"   = "value3" # not presented on project. This field will not be added
        "Number1" = "66"
    }

    # Act
    $result = Edit-ProjectItemWithValues -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Values $data -FieldSlug $FieldSlug

    # Assert
    $result = get-projectitemstaged -Owner $owner -ProjectNumber $projectNumber

    $itemStaged = $result.$itemId
    Assert-Count -Expected 3 -Presented $itemStaged.Values

    foreach ($fieldName in  @("Text1", "Text2", "Number1")) {
        $value = ($itemStaged.Values | Where-Object { $_.Field.name -eq $($fieldSlug + $fieldName) }).Value
        Assert-AreEqual -Expected $data.$fieldName -Presented $value
    }

}