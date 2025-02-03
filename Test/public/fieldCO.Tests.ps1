function Test_NewFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"

    $field = New-FieldCO -Id "1" -Name "Test Field" -Type "String" -Value "Test Value" -SingleSelectOptions "Option1,Option2" -IterationsConfiguration "Iteration1,Iteration2"
    
    Assert-AreEqual -Expected "1" -Presented $field.Id
    Assert-AreEqual -Expected "Test Field" -Presented $field.Name
    Assert-AreEqual -Expected "String" -Presented $field.Type
    Assert-AreEqual -Expected "Test Value" -Presented $field.Value
    Assert-AreEqual -Expected "Option1,Option2" -Presented $field.SingleSelectOptions
    Assert-AreEqual -Expected "Iteration1,Iteration2" -Presented $field.IterationsConfiguration
}

function Test_TestFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"
    
    $validField = @{
        Id = "1"
        Name = "Test Field"
        Type = "String"
        Value = "Test Value"
        SingleSelectOptions = "Option1,Option2"
        IterationsConfiguration = "Iteration1,Iteration2"
    }
    
    $invalidField = @{
        Id = ""
        Name = ""
        Type = ""
        Value = ""
    }
    
    $validSingleSelectField = @{
        Id = "1"
        Name = "Test Field"
        Type = "SINGLE_SELECT"
        Value = "Test Value"
        SingleSelectOptions = "Option1,Option2"
    }
    
    $invalidSingleSelectField = @{
        Id = "1"
        Name = "Test Field"
        Type = "SINGLE_SELECT"
        Value = "Test Value"
        SingleSelectOptions = ""
    }
    
    $validIterationField = @{
        Id = "1"
        Name = "Test Field"
        Type = "ITERATION"
        Value = "Test Value"
        IterationsConfiguration = "Iteration1,Iteration2"
    }
    
    $invalidIterationField = @{
        Id = "1"
        Name = "Test Field"
        Type = "ITERATION"
        Value = "Test Value"
        IterationsConfiguration = ""
    }
    
    Assert-IsTrue -Condition (Test-FieldCO -Field $validField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidField)
    Assert-IsTrue -Condition (Test-FieldCO -Field $validSingleSelectField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidSingleSelectField)
    Assert-IsTrue -Condition (Test-FieldCO -Field $validIterationField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidIterationField)
}

function Test_ConvertToFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"

    $json = '{"Id":"1","Name":"Test Field","Type":"String","Value":"Test Value","SingleSelectOptions":"Option1,Option2","IterationsConfiguration":"Iteration1,Iteration2"}'
    $field = ConvertTo-FieldCO -Json $json
    
    Assert-AreEqual -Expected "1" -Presented $field.Id
    Assert-AreEqual -Expected "Test Field" -Presented $field.Name
    Assert-AreEqual -Expected "String" -Presented $field.Type
    Assert-AreEqual -Expected "Test Value" -Presented $field.Value
    Assert-AreEqual -Expected "Option1,Option2" -Presented $field.SingleSelectOptions
    Assert-AreEqual -Expected "Iteration1,Iteration2" -Presented $field.IterationsConfiguration
}
