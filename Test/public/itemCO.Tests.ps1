function Test_NewItemCO {
    . "$PSScriptRoot/../../private/itemCO.ps1"

    $item = New-ItemCO -Id "1" -Title "Test Item" -URL "http://example.com"
    
    Assert-AreEqual -Expected "1" -Presented $item.Id
    Assert-AreEqual -Expected "Test Item" -Presented $item.Title
    Assert-AreEqual -Expected "http://example.com" -Presented $item.URL
}

function Test_TestItemCO {
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
    . "$PSScriptRoot/../../private/itemCO.ps1"

    $json = '{"Id":"1","Title":"Test Item","URL":"http://example.com"}'
    $item = ConvertTo-ItemCO -Json $json
    
    Assert-AreEqual -Expected "1" -Presented $item.Id
    Assert-AreEqual -Expected "Test Item" -Presented $item.Title
    Assert-AreEqual -Expected "http://example.com" -Presented $item.URL
    Assert-IsTrue -Condition ($item -is [PSCustomObject])

    $json | ConvertTo-ItemCO | ForEach-Object {
        Assert-AreEqual -Expected "1" -Presented $_.Id
        Assert-AreEqual -Expected "Test Item" -Presented $_.Title
        Assert-AreEqual -Expected "http://example.com" -Presented $_.URL
        Assert-IsTrue -Condition ($_ -is [PSCustomObject])
        Assert-IsTrue -Condition (Test-ItemCO -Item $_)
    }
}
