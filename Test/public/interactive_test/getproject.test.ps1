function Test_Get_Project_ItemId_Equal_Case_Sensitive{
    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    # This project has -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    $item1 ="PVTI_lADNJr_OALnx2s4Fqq8F"
    $item2 ="PVTI_lADNJr_OALnx2s4Fqq8f"
    # Testing that we can load this 

    # MockCallJson -Command "Invoke-GitHubOrgProjectWithFields -Owner github -ProjectNumber 20521" -Filename "invoke-GitHubOrgProjectWithFields-github-20521.json"
    MockCallJson -Command "GitHubOrgProjectWithFields" -Filename "invoke-GitHubOrgProjectWithFields-github-20521.json"

    $result = Get-Project -owner github -ProjectNumber 20521
    Assert-Count -Expected 86 -Presented $result.items.keys

    $result = Get-ProjectItem  -ItemId $item1
    Assert-AreEqual -Expected $item1 -Presented $result.id

    $result = Get-ProjectItem -ItemId $item2
    Assert-AreEqual -Expected $item2 -Presented $result.id
}