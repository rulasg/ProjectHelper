function Test_Get_Project_ItemId_Equal_Case_Sensitive{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # This project has -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    $item1 ="PVTI_lADNJr_OALnx2s4Fqq8F"
    $item2 ="PVTI_lADNJr_OALnx2s4Fqq8f"
    $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p"
    $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P"
    # Testing that we can load this 

    MockCall_GitHubOrgProjectWithFields -Owner github -ProjectNumber 20521 -FileName "invoke-GitHubOrgProjectWithFields-github-20521.json"
    # MockCallJson -Command 'Invoke-GitHubOrgProjectWithFields -Owner github -ProjectNumber 20521 -afterFields "" -afterItems ""' -Filename "invoke-GitHubOrgProjectWithFields-github-20521.json"

    $result = Get-Project -owner github -ProjectNumber 20521
    Assert-Count -Expected 86 -Presented $result.items.keys

    $result1 = Get-ProjectItem  -ItemId $item1
    Assert-IsNotNull -Object $result1
    Assert-AreEqual -Expected $result1.id -Presented $result.items.$item1.id

    $result2 = Get-ProjectItem  -ItemId $item2
    Assert-IsNotNull -Object $result2
    Assert-AreEqual -Expected $result2.id -Presented $result.items.$item2.id

    $result3 = Get-ProjectItem  -ItemId $item3
    Assert-IsNotNull -Object $result3
    Assert-AreEqual -Expected $result3.id -Presented $result.items.$item3.id

    $result4 = Get-ProjectItem  -ItemId $item4
    Assert-IsNotNull -Object $result4
    Assert-AreEqual -Expected $result4.id -Presented $result.items.$item4.id

    
}

function Test_Get_Project_ItemId_Equal_Case_Sensitive_2{

    # Allthough this test pass this is not the case when 
    # adding Items to a @{}

    # This project has -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    $item1 ="PVTI_lADNJr_OALnx2s4Fqq8F"
    $item2 ="PVTI_lADNJr_OALnx2s4Fqq8f"
    $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p"
    $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P"
    # Testing that we can load this 

    $ht = @{}
    $ht[$item1] = "item1"
    $ht[$item2] = "item2"
    $ht[$item3] = "item3"
    $ht[$item4] = "item4"

    $ht2 = @{}
    $ht2 += $ht
}