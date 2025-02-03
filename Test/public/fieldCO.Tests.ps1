function Test_NewFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"

    $field = New-FieldCO -Id "1" -Name "Test Field" -DataType "TEXT" -Value "Test Value" -SingleSelectOptions "Option1,Option2" -IterationsConfiguration "Iteration1,Iteration2"
    
    Assert-AreEqual -Expected "1" -Presented $field.Id
    Assert-AreEqual -Expected "Test Field" -Presented $field.Name
    Assert-AreEqual -Expected "TEXT" -Presented $field.DataType
    Assert-AreEqual -Expected "Test Value" -Presented $field.Value
    Assert-AreEqual -Expected "Option1,Option2" -Presented $field.SingleSelectOptions
    Assert-AreEqual -Expected "Iteration1,Iteration2" -Presented $field.IterationsConfiguration
}

function Test_TestFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"
    
    $validField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "TEXT"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = ""
    }
    
    $invalidField = @{
        Id = ""
        Name = ""
        DataType = ""
        Value = ""
    }
    
    $validSingleSelectField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "SINGLE_SELECT"
        Value = "Test Value"
        SingleSelectOptions = "Option1,Option2"
        IterationsConfiguration = ""
    }
    
    $invalidSingleSelectField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "SINGLE_SELECT"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = ""
    }
    
    $validIterationField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "ITERATION"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = "Iteration1,Iteration2"
    }
    
    $invalidIterationField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "ITERATION"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = ""
    }
    
    $invalidDataTypeField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "INVALID"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = ""
    }
    
    $nonSingleSelectField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "TEXT"
        Value = "Test Value"
        SingleSelectOptions = "Option1,Option2"
        IterationsConfiguration = ""
    }
    
    $nonIterationField = @{
        Id = "1"
        Name = "Test Field"
        DataType = "TEXT"
        Value = "Test Value"
        SingleSelectOptions = ""
        IterationsConfiguration = "Iteration1,Iteration2"
    }
    
    Assert-IsTrue -Condition (Test-FieldCO -Field $validField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidField)
    Assert-IsTrue -Condition (Test-FieldCO -Field $validSingleSelectField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidSingleSelectField)
    Assert-IsTrue -Condition (Test-FieldCO -Field $validIterationField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidIterationField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $invalidDataTypeField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $nonSingleSelectField)
    Assert-IsFalse -Condition (Test-FieldCO -Field $nonIterationField)
}

function Test_ConvertToFieldCO {
    . "$PSScriptRoot/../../private/fieldCO.ps1"

    $jsonText = @'
    {
        "Id": "1",
        "Name": "Test Field",
        "DataType": "TEXT",
        "Value": "Test Value",
        "SingleSelectOptions": "",
        "IterationsConfiguration": ""
    }
'@
    $field = ConvertTo-FieldCO -Json $jsonText
    
    Assert-AreEqual -Expected "1" -Presented $field.Id
    Assert-AreEqual -Expected "Test Field" -Presented $field.Name
    Assert-AreEqual -Expected "TEXT" -Presented $field.DataType
    Assert-AreEqual -Expected "Test Value" -Presented $field.Value
    Assert-StringIsNullOrEmpty -Presented $field.SingleSelectOptions
    Assert-StringIsNullOrEmpty -Presented $field.IterationsConfiguration
    Assert-IsTrue -Condition ($field -is [PSCustomObject])
    Assert-IsTrue -Condition (Test-FieldCO -Field $field)

    $jsonSingleSelect = @'
    {
        "Id": "2",
        "Name": "Single Select Field",
        "DataType": "SINGLE_SELECT",
        "Value": "Option1",
        "SingleSelectOptions": "Option1,Option2",
        "IterationsConfiguration": ""
    }
'@
    $fieldSingleSelect = ConvertTo-FieldCO -Json $jsonSingleSelect
    
    Assert-AreEqual -Expected "2" -Presented $fieldSingleSelect.Id
    Assert-AreEqual -Expected "Single Select Field" -Presented $fieldSingleSelect.Name
    Assert-AreEqual -Expected "SINGLE_SELECT" -Presented $fieldSingleSelect.DataType
    Assert-AreEqual -Expected "Option1" -Presented $fieldSingleSelect.Value
    Assert-AreEqual -Expected "Option1,Option2" -Presented $fieldSingleSelect.SingleSelectOptions
    Assert-StringIsNullOrEmpty -Presented $fieldSingleSelect.IterationsConfiguration
    Assert-IsTrue -Condition ($fieldSingleSelect -is [PSCustomObject])
    Assert-IsTrue -Condition (Test-FieldCO -Field $fieldSingleSelect)

    $jsonIteration = @'
    {
        "Id": "3",
        "Name": "Iteration Field",
        "DataType": "ITERATION",
        "Value": "Iteration1",
        "SingleSelectOptions": "",
        "IterationsConfiguration": "Iteration1,Iteration2"
    }
'@
    $fieldIteration = ConvertTo-FieldCO -Json $jsonIteration
    
    Assert-AreEqual -Expected "3" -Presented $fieldIteration.Id
    Assert-AreEqual -Expected "Iteration Field" -Presented $fieldIteration.Name
    Assert-AreEqual -Expected "ITERATION" -Presented $fieldIteration.DataType
    Assert-AreEqual -Expected "Iteration1" -Presented $fieldIteration.Value
    Assert-StringIsNullOrEmpty -Presented $fieldIteration.SingleSelectOptions
    Assert-AreEqual -Expected "Iteration1,Iteration2" -Presented $fieldIteration.IterationsConfiguration
    Assert-IsTrue -Condition ($fieldIteration -is [PSCustomObject])
    Assert-IsTrue -Condition (Test-FieldCO -Field $fieldIteration)

    $jsonText | ConvertTo-FieldCO | ForEach-Object {
        Assert-AreEqual -Expected "1" -Presented $_.Id
        Assert-AreEqual -Expected "Test Field" -Presented $_.Name
        Assert-AreEqual -Expected "TEXT" -Presented $_.DataType
        Assert-AreEqual -Expected "Test Value" -Presented $_.Value
        Assert-StringIsNullOrEmpty -Presented $_.SingleSelectOptions
        Assert-StringIsNullOrEmpty -Presented $_.IterationsConfiguration
        Assert-IsTrue -Condition ($_ -is [PSCustomObject])
        Assert-IsTrue -Condition (Test-FieldCO -Field $_)
    }

    $jsonSingleSelect | ConvertTo-FieldCO | ForEach-Object {
        Assert-AreEqual -Expected "2" -Presented $_.Id
        Assert-AreEqual -Expected "Single Select Field" -Presented $_.Name
        Assert-AreEqual -Expected "SINGLE_SELECT" -Presented $_.DataType
        Assert-AreEqual -Expected "Option1" -Presented $_.Value
        Assert-AreEqual -Expected "Option1,Option2" -Presented $_.SingleSelectOptions
        Assert-StringIsNullOrEmpty -Presented $_.IterationsConfiguration
        Assert-IsTrue -Condition ($_ -is [PSCustomObject])
        Assert-IsTrue -Condition (Test-FieldCO -Field $_)
    }

    $jsonIteration | ConvertTo-FieldCO | ForEach-Object {
        Assert-AreEqual -Expected "3" -Presented $_.Id
        Assert-AreEqual -Expected "Iteration Field" -Presented $_.Name
        Assert-AreEqual -Expected "ITERATION" -Presented $_.DataType
        Assert-AreEqual -Expected "Iteration1" -Presented $_.Value
        Assert-StringIsNullOrEmpty -Presented $_.SingleSelectOptions
        Assert-AreEqual -Expected "Iteration1,Iteration2" -Presented $_.IterationsConfiguration
        Assert-IsTrue -Condition ($_ -is [PSCustomObject])
        Assert-IsTrue -Condition (Test-FieldCO -Field $_)
    }
}
