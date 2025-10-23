
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
        repoid = $repo.id
        title        = $Title | ConvertTo-InvokeParameterString
        body         = $Body | ConvertTo-InvokeParameterString
    }

    $response = Invoke-MyCommand -Command CreateIssue -Parameters $params

    $issue = $response.data.createIssue.issue

    if ( ! $issue ) {
        throw "Issue not created properlly"
    }

    # TODO: Consider adding the issue to the project

    $ret = $issue.url

    return $ret

} Export-ModuleMember -Function New-ProjectIssueDirect

function New-ProjectIssue {
    [CmdletBinding()]
    [Alias("npi")]
    param(
        #ProjectOwner
        [Parameter()][string]$ProjectOwner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, Position = 1)][string]$RepoOwner,
        [Parameter(Mandatory, Position = 2)][string]$RepoName,
        [Parameter(Mandatory, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body
    )

    try{

        # Create Issue
        $url = New-ProjectIssueDirect -RepoOwner $RepoOwner -RepoName $RepoName -Title $Title -Body $Body
        
        if(! $url ){
            "Issue could not be created" | Write-MyError
            return $null
        }
        
        # Add issue to project
        $ProjectOwner,$ProjectNumber = Get-OwnerAndProjectNumber -Owner $ProjectOwner -ProjectNumber $ProjectNumber
        
        $itemId = Add-ProjectItem -Owner $ProjectOwner -ProjectNumber $ProjectNumber -Url $url
        
        return $itemId
    }
    catch{
        throw "Error creating issue and adding to project: $_"
    }

} Export-ModuleMember -Function New-ProjectIssue -Alias npi