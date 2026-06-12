function Test_GetProjectConfig{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number
    MockCall_GetProject $p -SkipItems -Cache

    $configTemplate = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@

    # Arrange actual readme value
    $actualconfigString = @{ module = "OldModule" } | ConvertTo-Json
    $actualReadme = $configTemplate -replace '{module}', $actualconfigString
    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadme
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadme -Present $db.readme

    # Act
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected "OldModule" -Present $result.module
}

function Test_SetProjectConfig_Empty{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems -Cache

    $configTemplate = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@

    # Arrange actual readme value
    $actualReadme = " "
    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadme
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadme -Present $db.readme

    ## Assert call
    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = ($configTemplate -replace '{module}', $configJson)
    $targetReadmeBase64 = $targetreadme | ConvertTo-Base64
    MockCallJson -Command "Invoke-UpdateProjectV2 -ProjectId $projectId -ReadMeBase64 $targetReadmeBase64" -Filename "Invoke-UpdateProjectV2-octodemo-700-readme.json"

    # Act
    Set-ProjectConfig -Owner $owner -ProjectNumber $projectNumber -Config $config

    # Get the config again to verify it was saved
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $config.module -Present $result.module
}

function Test_SetProjectConfig_readme_WithContentString{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems -Cache

    $configTemplate = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@

    # Arrange actual readme value
    $actualReadmeString = "This is some readme content that should be preserved"
    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadmeString
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadmeString -Present $db.readme

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = $actualReadmeString + "`n`n" + ($configTemplate -replace '{module}', $configJson)
    $targetReadmeBase64 = $targetreadme | ConvertTo-Base64
    MockCallJson -Command "Invoke-UpdateProjectV2 -ProjectId $projectId -ReadMeBase64 $targetReadmeBase64" -Filename "Invoke-UpdateProjectV2-octodemo-700-readme.json"

    # Act
    Set-ProjectConfig -Owner $owner -ProjectNumber $projectNumber -Config $config

    # Get the config again to verify it was saved
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $config.module -Present $result.module
}

function Test_SetProjectConfig_readme_WithContentConfig{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems -Cache

    $configTemplate = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@

    # Arrange actual readme value
    $actualconfigString = @{ module = "OldModule" } | ConvertTo-Json
    $actualReadme = $configTemplate -replace '{module}', $actualconfigString
    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadme
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadme -Present $db.readme

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = ($configTemplate -replace '{module}', $configJson)
    $targetReadmeBase64 = $targetreadme | ConvertTo-Base64
    MockCallJson -Command "Invoke-UpdateProjectV2 -ProjectId $projectId -ReadMeBase64 $targetReadmeBase64" -Filename "Invoke-UpdateProjectV2-octodemo-700-readme.json"

    # Act
    Set-ProjectConfig -Owner $owner -ProjectNumber $projectNumber -Config $config

    # Get the config again to verify it was saved
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $config.module -Present $result.module
}

function Test_SetProjectConfig_readme_WithContentConfigAndString{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems -Cache

    $configTemplate = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@

    # Arrange actual readme value
    $actualReadmeString = "This is some readme content that should be preserved"
    $actualconfigString = @{ module = "OldModule" } | ConvertTo-Json
    $actualReadme = $actualReadmeString + "`n`n" + ($configTemplate -replace '{module}', $actualconfigString)
    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadme
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadme -Present $db.readme

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = $actualReadmeString + "`n`n" + ($configTemplate -replace '{module}', $configJson)
    $targetReadmeBase64 = $targetreadme | ConvertTo-Base64
    MockCallJson -Command "Invoke-UpdateProjectV2 -ProjectId $projectId -ReadMeBase64 $targetReadmeBase64" -Filename "Invoke-UpdateProjectV2-octodemo-700-readme.json"

    # Act
    Set-ProjectConfig -Owner $owner -ProjectNumber $projectNumber -Config $config

    # Get the config again to verify it was saved
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $config.module -Present $result.module
}