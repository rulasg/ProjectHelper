function Test__Get_Project_ItemId_Equal_Case_Sensitive{
    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    # This project has -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    # PVTI_lADNJr_OALnx2s4Fqq8F
    # PVTI_lADNJr_OALnx2s4Fqq8f
    # Testing that we can load this 

    MockCallJson -Command "Invoke-GitHubOrgProjectWithFields -Owner github -ProjectNumber 20521" -Filename "invoke-GitHubOrgProjectWithFields-github-20521.json"
    
    $result = Get-Project -owner github -ProjectNumber 20521 -Verbose

    Assert-NotImplemented
}