function Test_NewItemCO {
    <#
    .SYNOPSIS
    Tests the New-ItemCO function.
    #>
    . "$PSScriptRoot/../../private/itemCO.ps1"

    $item = New-ItemCO -Id "1" -Title "Test Item" -URL "http://example.com"
    
    Assert-AreEqual -Expected "1" -Presented $item.Id
    Assert-AreEqual -Expected "Test Item" -Presented $item.Title
    Assert-AreEqual -Expected "http://example.com" -Presented $item.URL
}

function Test_TestItemCO {
    <#
    .SYNOPSIS
    Tests the Test-ItemCO function.
    #>
    . "$PSScriptRoot/../../private/itemCO.ps1"
    
    $validItem = @{
        Id = "1"
        Title = "Test Item"
        URL = "http://example.com"
    }
    
    $invalidItem = @{
        Id = ""
        Title = ""
        URL = ""
    }
    
    Assert-IsTrue -Condition (Test-ItemCO -Item $validItem)
    Assert-IsFalse -Condition (Test-ItemCO -Item $invalidItem)
}

function Test_ConvertToItemCO {
    <#
    .SYNOPSIS
    Tests the ConvertTo-ItemCO function.
    #>
    . "$PSScriptRoot/../../private/itemCO.ps1"

    $json = '{"Id":"1","Title":"Test Item","URL":"http://example.com"}'
    $item = ConvertTo-ItemCO -Json $json
    
    Assert-AreEqual -Expected "1" -Presented $item.Id
    Assert-AreEqual -Expected "Test Item" -Presented $item.Title
    Assert-AreEqual -Expected "http://example.com" -Presented $item.URL
}
