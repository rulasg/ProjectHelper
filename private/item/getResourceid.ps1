

Set-MyInvokeCommandAlias -Alias GetIssueOrPullRequest -Command 'Invoke-GetIssueOrPullRequest -Url {url}'


function Get-ContentIdFromUrlDirect{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Url
    )

    $params = @{
        url = $Url
    }

    $response = Invoke-MyCommand -Command GetIssueOrPullRequest -Parameters $params

    if($response.data.resource){
        $ret = $response.data.resource.id
    } else {
        "Resource not found for URL [$Url]" | Write-MyError
        $ret = $null
    }

    return $ret
} Export-ModuleMember -Function Get-ContentIdFromUrlDirect