function Test_Get_Project_ItemId_Equal_Case_Sensitive{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # Project -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    # Mock the scenario for testing in 'projectV2.json'
    $item1 ="PVTI_lADNJr_OALnx2s4Fqq8F"
    $item2 ="PVTI_lADNJr_OALnx2s4Fqq8f"
    $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p"
    $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P"
    # Testing that we can load this 

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Get-Project -owner $owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 12 -Presented $result.items.keys

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

    $item1 ="PVTI_lADNJr_OALnx2s4Fqq8F"
    $item2 ="PVTI_lADNJr_OALnx2s4Fqq8f"
    $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p"
    $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P"
    # Testing that we can load this 

    # By default hashTables are case insensitive in the name of the keys

    # This should NOT work but it does :/

    $ht11 = @{} # Case insensitive by default

    $ht11[$item1] = "item1"
    $ht11[$item2] = "item2"
    $ht11[$item3] = "item3"
    $ht11[$item4] = "item4"

    $ht12 = @{}
    $ht12 += $ht11

    # This should work

    $ht21 = New-Object System.Collections.Hashtable # Case sensitive

    $ht21[$item1] = "item1"
    $ht21[$item2] = "item2"
    $ht21[$item3] = "item3"
    $ht21[$item4] = "item4"

    $ht22 = @{}
    $ht22 += $ht22
}