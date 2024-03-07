function ProjectHelperTest_GitHubProjectFields_SUCCESS{

    $Owner = "someOwner" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18

    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    $result = Invoke-GitHubOrgProjectWithFields -Owner $owner -Project $projectnumber

    Assert-AreEqual -Expected $ProjectNumber -Presented $result.data.organization.projectv2.number
    Assert-AreEqual -Expected "PVT_kwDOBCrGTM4ActQa" -Presented $result.data.organization.projectv2.id
    Assert-Count -Expected $itemsCount -Presented $result.data.organization.projectv2.items.nodes
    Assert-Count -Expected $fieldsCount -Presented $result.data.organization.projectv2.fields.nodes

    Reset-Mock_GitHubProjectFields
}