function Test_Get_Project_ItemId_Equal_Case_Sensitive {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    MockCall_GetProject_700_CaseSensitive
    
    # Project -Owner github -ProjectNumber 20521 has two items with the same Id case sensitive
    # Forces project 700n with two item ids with case difference last leter of their id
    $item1 = "PVTI_lADOAlIw4c4BCe3Vzgec8pU"
    $item2 = "PVTI_lADOAlIw4c4BCe3Vzgec8pu"

    # Act
    $result = Get-Project -owner $owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected $p.items.totalCount -Presented $result.items.keys

    $result1 = Get-ProjectItem -ItemId $item1
    Assert-IsNotNull -Object $result1
    Assert-AreEqual -Expected $result1.id -Presented $result.items.$item1.id

    $result2 = Get-ProjectItem -ItemId $item2
    Assert-IsNotNull -Object $result2
    Assert-AreEqual -Expected $result2.id -Presented $result.items.$item2.id

}

function Test_Get_Project_ItemId_Equal_Case_Sensitive_2 {

    # Allthough this test pass this is not the case when
    # adding Items to a @{}

    $item1 = "PVTI_lADNJr_OALnx2s4Fqq8F" # Ending Capital F
    $item2 = "PVTI_lADNJr_OALnx2s4Fqq8f" # Ending Small f
    $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p" # Ending Small p
    $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P" # Ending Capital P
    # Testing that we can load this

    # By default hashTables are case insensitive in the name of the keys

    # This should NOT work but it does :/

    $ht11 = @{} # Case insensitive by default

    Assert-AreEqual -Expected "System.Collections.Hashtable"-Presented $($ht11.GetType().FullName)

    $ht11[$item1] = "item1"
    $ht11[$item2] = "item2"
    $ht11[$item3] = "item3"
    $ht11[$item4] = "item4"

    $ht12 = @{}
    $ht12 += $ht11

    # This should work

    $ht21 = New-Object System.Collections.Hashtable # Case sensitive

    Assert-AreEqual -Expected "System.Collections.Hashtable"-Presented $($ht21.GetType().FullName)

    $ht21[$item1] = "item1"
    $ht21[$item2] = "item2"
    $ht21[$item3] = "item3"
    $ht21[$item4] = "item4"

    $ht22 = @{}
    $ht22 += $ht22

    
}

function Test_Get_Project_ItemId_Equal_Case_Sensitive_4 {
    # This should work using the private funciton

    Invoke-PrivateContext {

        $item1 = "PVTI_lADNJr_OALnx2s4Fqq8F" # Ending Capital F
        $item2 = "PVTI_lADNJr_OALnx2s4Fqq8f" # Ending Small f
        $item3 = "PVTI_lADNJr_OALnx2s4Fqq8p" # Ending Small p
        $item4 = "PVTI_lADNJr_OALnx2s4Fqq8P" # Ending Capital P

        # Act

        $source = New-HashTable
        $destination = New-HashTable

        $source[$item1] = "item1"
        $source[$item2] = "item2"
        $source[$item3] = "item3"
        $source[$item4] = "item4"

        Assert-Count -Expected 4 -Presented $source.keys

        # This will throw. 
        # Wrong way to merge hashtables
        $hasthrow = $false
        try{
            $destination += $source
        } catch {
            $hasthrow = $true
        }
        Assert-IsTrue -Condition $hasthrow

        # Correct way to merge hashtables

        foreach($key in $source.keys) {
            $destination.$key = $source[$key]
        }

        Assert-Count -Expected 4 -Presented $destination.keys
    }
}


function Test_Get_Project_ItemId_Equal_Case_Sensitive_3{

    # Test 1 - Wrong. We lose items

    $source = @{}
    $destination = @{}

    $source.kk = "value"
    $source.Kk = "value"

    Assert-Count -Expected 1 -Presented $source.keys

    $destination += $source

    Assert-Count -Expected 1 -Presented $destination.keys

    # Test 2 - Wrong we throw on merges

    $source = New-Object System.Collections.Hashtable
    $destination = New-Object System.Collections.Hashtable

    $source.kk = "value"
    $source.Kk = "value"

    Assert-Count -Expected 2 -Presented $source.keys

    $hasthrow = $false
    try{
        $destination += $source
    } catch {
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasthrow


    # Test 3 - Wrong we throw on merges

    $source = New-Object System.Collections.Hashtable
    $destination = @{}

    $source.kk = "value"
    $source.Kk = "value"
    Assert-Count -Expected 2 -Presented $source.keys

    $hasthrow = $false
    try{
        $destination += $source
    } catch {
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasthrow

    # Test 4 - Wrong we lose items

    $source = @{}
    $destination = New-Object System.Collections.Hashtable

    $source.kk = "value"
    $source.Kk = "value"

    Assert-Count -Expected 1 -Presented $source.keys

    $destination += $source

    Assert-Count -Expected 1 -Presented $destination.keys

}