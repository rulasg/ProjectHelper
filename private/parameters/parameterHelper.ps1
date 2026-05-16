function Get-ParameterValue {
    param(
        [string]$CommandText,
        [string]$ParameterName,
        [string]$ParameterAlias
    )
    
    # Match parameter followed by either quoted string or unquoted word
    if ($CommandText -match "-$ParameterName\s+(?:(?:`"([^`"]*)`")|(?:'([^']*)')|([^\s-]+))") {
        return $matches[1], $matches[2], $matches[3] | Where-Object { $_ }
    }
    
    # If ParameterName not found, try ParameterAlias
    if ($ParameterAlias -and $CommandText -match "-$ParameterAlias\s+(?:(?:`"([^`"]*)`")|(?:'([^']*)')|([^\s-]+))") {
        return $matches[1], $matches[2], $matches[3] | Where-Object { $_ }
    }
    
    return $null
}

# write a function that returns a Script block
function Get-ArgumentCompleterScriptBlock($Name) {

    $Script_GetValidFieldsNames = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        "Procesing $CommandName -$parameterName with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

        Get-ValidFieldsNames | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
    }

    $Script_GetValidNames_FieldName = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        "Procesing $CommandName -$parameterName with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

        $fieldname = Get-ParameterValue -CommandText $commandAst.Extent.Text -ParameterName "FieldName" -ParameterAlias "F"

        "Extracted FieldName: $fieldname" | Write-MyDebug -Section "ArgumentCompleter"

        if( -not $fieldname ) { return }

        Get-ValidNames $fieldname | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
    }

    $Script_GetValidNames_ParameterName = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        "Procesing $CommandName -$parameterName with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

        Get-ValidNames $parameterName | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
    }
    switch ($Name) {
        "Script_GetValidFieldsNames" { return $Script_GetValidFieldsNames }
        "Script_GetValidNames_FieldName" { return $Script_GetValidNames_FieldName }
        "Script_GetValidNames_ParameterName" { return $Script_GetValidNames_ParameterName }
        default { throw "Wrong script name $Name"}
    }
    
}