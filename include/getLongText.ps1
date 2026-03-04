
$EditFileAlias = $MODULE_NAME + "_EditFile"
$EditFileAliasCode = $MODULE_NAME + "_EditFileCode"
Set-MyInvokeCommandAlias -Alias $EditFileAliasCode -Command 'code -w "{path}"'
Set-MyInvokeCommandAlias -Alias $EditFileAlias -Command "$MODULE_NAME\Invoke-$($MODULE_NAME)EditFile -Text '{text}'"

function Invoke-GetLongText{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Text
    )

    $tmpFilePath = "temp:" | Convert-Path | Join-Path -ChildPath "LongText_$([Guid]::NewGuid().ToString()).md"

    New-Item -Path $tmpFilePath -ItemType File -Force | Out-Null

    if( -not [string]::IsNullOrWhiteSpace($Text)){
        # Join string array to single string
        $joinedValue = $Text -join [Environment]::NewLine

        # Write content without trailing newline
        Set-Content -Path $tmpFilePath -Value $joinedValue -NoNewline
    }

    Invoke-MyCommand -Command $EditFileAliasCode -Parameters @{ path = $tmpFilePath }

    $content = Get-Content $tmpFilePath -Raw

    Microsoft.PowerShell.Management\Remove-Item $tmpFilePath -Force

    return $content
} Export-ModuleMember -Function Invoke-GetLongText

function Get-LongText{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Text
    )

    $ret = Invoke-MyCommand -Command $EditFileAliasCode  -Parameters @{ text = $Text }

    return $ret

}