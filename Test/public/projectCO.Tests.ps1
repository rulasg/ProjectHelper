# private/projectCO.Tests.ps1

function Test_NewProjectCO {
    . "$PSScriptRoot/../../private/projectCO.ps1"

    $project = New-ProjectCO -Id "1" -Title "Test Project" -Number 123 -Owner "OwnerName" -URL "http://example.com" -Description "Test Description"

    Assert-AreEqual -Expected "1" -Presented $project.Id
    Assert-AreEqual -Expected "Test Project" -Presented $project.Title
    Assert-AreEqual -Expected 123 -Presented $project.Number
    Assert-AreEqual -Expected "OwnerName" -Presented $project.Owner
    Assert-AreEqual -Expected "http://example.com" -Presented $project.URL
    Assert-AreEqual -Expected "Test Description" -Presented $project.Description
}

function Test_TestProjectCO {
    . "$PSScriptRoot/../../private/projectCO.ps1"

    $validProject = @{
        Id = "1"
        Title = "Test Project"
        Number = 123
        Owner = "OwnerName"
        URL = "http://example.com"
        Description = "Test Description"
    }

    $invalidProject = @{
        Id = ""
        Title = ""
        Number = 0
        Owner = ""
        URL = ""
        Description = ""
    }

    Assert-IsTrue -Condition (Test-ProjectCO -Project $validProject)
    Assert-IsFalse -Condition (Test-ProjectCO -Project $invalidProject)
}

function Test_ConvertToProjectCO {
    . "$PSScriptRoot/../../private/projectCO.ps1"

    $json = '{"Id":"1","Title":"Test Project","Number":123,"Owner":"OwnerName","URL":"http://example.com","Description":"Test Description"}'
    $project = ConvertTo-ProjectCO -Json $json

    Assert-AreEqual -Expected "1" -Presented $project.Id
    Assert-AreEqual -Expected "Test Project" -Presented $project.Title
    Assert-AreEqual -Expected 123 -Presented $project.Number
    Assert-AreEqual -Expected "OwnerName" -Presented $project.Owner
    Assert-AreEqual -Expected "http://example.com" -Presented $project.URL
    Assert-AreEqual -Expected "Test Description" -Presented $project.Description
    Assert-IsTrue -Condition ($project -is [PSCustomObject])

    $json | ConvertTo-ProjectCO | ForEach-Object {
        Assert-AreEqual -Expected "1" -Presented $_.Id
        Assert-AreEqual -Expected "Test Project" -Presented $_.Title
        Assert-AreEqual -Expected 123 -Presented $_.Number
        Assert-AreEqual -Expected "OwnerName" -Presented $_.Owner
        Assert-AreEqual -Expected "http://example.com" -Presented $_.URL
        Assert-AreEqual -Expected "Test Description" -Presented $_.Description
        Assert-IsTrue -Condition ($_ -is [PSCustomObject])
        Assert-IsTrue -Condition (Test-ProjectCO -Project $_)
    }
}