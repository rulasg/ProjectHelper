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