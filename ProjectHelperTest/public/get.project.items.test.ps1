function ProjectHelperTest_GetProjetItems_SUCCESS{

    Reset-InvokeCommandMock

    $Owner = "someOwner" ; $ProjectNumber = 666

    MockCall -Command "gh project item-list $ProjectNumber --owner $owner --format json" -filename project_item_list_3.json
    MockCall -Command "gh project field-list $ProjectNumber --owner $owner --format json" -filename project_field_list_15.json

    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 3 -Presented $result

    Reset-InvokeCommandMock

    # Can call without mock because it will use the database information
    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 3 -Presented $result

}

function ProjectHelperTest_GetProjetItems_OrgProjectWithFields_SUCCESS{

    $owner = "solidifydemo" ; $projectnumber = 164

    # Arrange
    $fileName = $MOCK_PATH | Join-Path -ChildPath 'orgprojectwithfields.json'
    $content = Get-Content -Path $fileName | Out-String
    Set-Mock_GitHubProjectFields -Content $content

    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 12 -Presented $result

    Reset-Mock_GitHubProjectFields

    # Set mock that will not be called as the second call will use the database information
    Set-Mock_GitHubProjectFields -Content "This data will throw if github call is made"

    $result = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 12 -Presented $result

    Reset-Mock_GitHubProjectFields

}

#