
$PROJECT_CONFIG_TEMPLATE = @'
<details><summary>ProjectHelper_Configuration</summary><p>
{module}
</p></details>
'@
function Update-Mock_Project_ReadMe_With_String_And_Config($p, $module, $extraString = ""){

    $owner = $p.Owner
    $projectNumber = $p.number
    MockCall_GetProject $p -SkipItems -Cache
    
    $actualReadme = $extraString

    # Add config section if module is provided
    if(-not [string]::IsNullOrWhiteSpace($module)){
        $actualReadme += -not [string]::IsNullOrWhiteSpace($extraString) ? "`n`n" : ""
        $actualconfigString = @{ module = $module } | ConvertTo-Json
        $actualReadme += $PROJECT_CONFIG_TEMPLATE -replace '{module}', $actualconfigString
    } 

    Update-Mock_DatabaseFileWithField "db-$Owner-$ProjectNumber-project.json" "readme" $actualReadme

    # Assert configuration
    $db = Get-Project -owner $owner -projectNumber $projectNumber -SkipItems
    Assert-AreEqual -Expected $actualReadme -Present $db.readme
}