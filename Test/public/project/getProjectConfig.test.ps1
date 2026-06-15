function Test_GetProjectConfig{

    $moduleName = "OldModule"

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number

    Update-Mock_Project_ReadMe_With_String_And_Config $p $moduleName

    # Act
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $moduleName -Present $result.module
}

function Test_SetProjectConfig_Empty{

    $moduleName = " "

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number ; $projectId = $p.id

    Update-Mock_Project_ReadMe_With_String_And_Config $p $moduleName

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = ($PROJECT_CONFIG_TEMPLATE -replace '{module}', $configJson)
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

    # update readme
    $actualReadmeString = "This is some readme content that should be preserved"
    Update-Mock_Project_ReadMe_With_String_And_Config $p -extraString $actualReadmeString

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = $actualReadmeString + "`n`n" + ($PROJECT_CONFIG_TEMPLATE -replace '{module}', $configJson)
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

    Update-Mock_Project_ReadMe_With_String_And_Config $p "OldModule"

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = ($PROJECT_CONFIG_TEMPLATE -replace '{module}', $configJson)
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

    # Arrange project readme
    $actualReadmeString = "This is some readme content that should be preserved"
    Update-Mock_Project_ReadMe_With_String_And_Config $p "OldModule" $actualReadmeString

    ## Arrange call
    $config = @{ module = "KkHelper" }
    $configJson = $config | ConvertTo-Json
    $targetreadme = $actualReadmeString + "`n`n" + ($PROJECT_CONFIG_TEMPLATE -replace '{module}', $configJson)
    $targetReadmeBase64 = $targetreadme | ConvertTo-Base64
    MockCallJson -Command "Invoke-UpdateProjectV2 -ProjectId $projectId -ReadMeBase64 $targetReadmeBase64" -Filename "Invoke-UpdateProjectV2-octodemo-700-readme.json"

    # Act
    Set-ProjectConfig -Owner $owner -ProjectNumber $projectNumber -Config $config

    # Get the config again to verify it was saved
    $result = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    Assert-IsNotNull -Object $result
    Assert-areEqual -Expected $config.module -Present $result.module
}