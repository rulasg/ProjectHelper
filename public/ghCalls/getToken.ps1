Set-MyinvokeCommandAlias -Alias GetToken -Command "gh auth token"

function Get-GithubToken{
    [CmdletBinding()]
    param()

    $token = Invoke-MyCommand -Command GetToken

    return $token
} Export-ModuleMember -Function Get-GithubToken