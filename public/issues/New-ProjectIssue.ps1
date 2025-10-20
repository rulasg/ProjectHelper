
Set-MyInvokeCommandAlias -Alias CreateIssue -Command 'Invoke-CreateIssue -RepositoryId {repoid} -Title "{title}" -Body "{body}"'

function New-ProjectIssueDirect {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)][string]$RepoOwner,
        [Parameter(Mandatory, Position = 2)][string]$RepoName,
        [Parameter(Mandatory, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body
    )

    $repo = Get-Repository -Owner $RepoOwner -Name $RepoName

    $params = @{
        repoid = $repo.Id
        title        = $Title
        body         = $Body
    }

    $response = Invoke-MyCommand -Command CreateIssue -Parameters $params

    $issue = $response.data.createIssue.issue

    if ( ! $issue ) {
        "Issue not created properlly" | Write-MyError
        return $null
    }

    # TODO: Consider adding the issue to the project

    $ret = $issue.url

    return $ret

} Export-ModuleMember -Function New-ProjectIssueDirect