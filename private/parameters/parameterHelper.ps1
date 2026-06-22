# ArgumentCompleter helper functions

# Return the list of available field names of the object
function Get-ProjectArgumentCompleter_FieldNames{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    "[F] Getting values for $commandName [$parameterName] with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

    Get-ValidFieldsNames | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
} Export-ModuleMember -Function Get-ProjectArgumentCompleter_FieldNames

# Parse the full command text to extract the FieldName parameter value, then return the valid names for that fieldname
function Get-ProjectArgumentCompleter_ParseCommandToExtractFieldName_FieldValues{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $fieldname = Get-ParameterValue -CommandText $commandAst.Extent.Text -ParameterName "FieldName" -ParameterAlias "F"
    
    "[F] Getting values for $commandName [$parameterName], parsed [$fieldname] from prompt [$( $commandAst.Extent.Text )] with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

    "Extracted FieldName: $fieldname" | Write-MyDebug -Section "ArgumentCompleter"

    if( -not $fieldname ) { return }

    Get-ValidNames $fieldname | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
} Export-ModuleMember -Function Get-ProjectArgumentCompleter_ParseCommandToExtractFieldName_FieldValues

# ParameterName will contain the FieldName. Return the Field Value names for this FieldName
function Get-ProjectArgumentCompleter_ParameterNameFieldValues{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    "[F] Getting values for $commandName [$parameterName] with word to complete: $wordToComplete" | Write-MyDebug -Section "ArgumentCompleter"

    Get-ValidNames $parameterName | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -Unique | ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_, $_, 'ParameterValue', $_) }
} Export-ModuleMember -Function Get-ProjectArgumentCompleter_ParameterNameFieldValues

# helper

# Parse CommandText to findn the value of a already filled parameter.
# Checks for parameter alias too.
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