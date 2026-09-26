
Set-MyInvokeCommandAlias -Alias CreateIssue -Command 'Invoke-CreateIssue -RepositoryId {repoid} -Title "{title}" -Body "{body}"'

function New-ProjectIssueDirect {
    [CmdletBinding()]
    [Alias("New-Issue")]
    param (
        [Parameter(Mandatory, Position = 1)][string]$RepoOwner,
        [Parameter(Mandatory, Position = 2)][string]$RepoName,
        [Parameter(Mandatory, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body,
        [Parameter()][switch]$OpenOnCreation
    )

    $repo = Get-Repository -Owner $RepoOwner -Name $RepoName

    if( ! $repo ) {
        "Repository $RepoOwner/$RepoName not found" | Write-MyError
        return $null
    }

    $params = @{
        repoid = $repo.id
        title        = $Title | ConvertTo-InvokeParameterString
        body         = $Body | ConvertTo-InvokeParameterString
    }

    $response = Invoke-MyCommand -Command CreateIssue -Parameters $params

    $issue = $response.data.createIssue.issue

    if ( ! $issue ) {
        throw "Issue not created properly"
    }

    $ret = $issue.url

    if( $OpenOnCreation ) {
        Open-Url $ret
    }

    return $ret

} Export-ModuleMember -Function New-ProjectIssueDirect -Alias New-Issue

function New-ProjectIssue {
    [CmdletBinding()]
    [Alias("npi")]
    param(
        #ProjectOwner
        [Parameter()][string]$ProjectOwner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, Position = 1)][Alias("Owner")][string]$RepoOwner,
        [Parameter(Mandatory, Position = 2)][string]$RepoName,
        [Parameter(Mandatory,ValueFromPipeline, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body,
        [Parameter()][switch]$OpenOnCreation
    )

    process {

        try{
            # Resolve Project
            ($ProjectOwner,$ProjectNumber) = Resolve-ProjectParameters -Owner $ProjectOwner -ProjectNumber $ProjectNumber

            # Check that the project owner and project number are resolved correctly
            if(-Not $ProjectOwner -or -Not $ProjectNumber){
                throw "Project owner or project number could not be resolved"
            }

            # Create Issue
            $url = New-ProjectIssueDirect -RepoOwner $RepoOwner -RepoName $RepoName -Title $Title -Body $Body
            
            if(! $url ){
                "Issue could not be created" | Write-MyError
                return $null
            }
            
            # Add issue to project
            $itemId = Add-ProjectItem -Owner $ProjectOwner -ProjectNumber $ProjectNumber -Url $url
            
            if( $OpenOnCreation ) {
                Open-Url $url
            }
            
            return $itemId
        }
        catch{
            throw "Error creating issue and adding to project: $_"
        }
    }

} Export-ModuleMember -Function New-ProjectIssue -Alias npi

function Copy-ProjectIssue {
    [CmdletBinding()]
    param(
        #Source Item
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        #ProjectOwner
        [Parameter()][string]$ProjectOwner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, Position = 1)][string]$RepoOwner,
        [Parameter(Mandatory, Position = 2)][string]$RepoName,
        [Parameter()][switch]$OpenOnCreation,
        [Parameter()][switch]$DoNotAddToProject

    )

    try{
        # Get Project
        ($ProjectOwner,$ProjectNumber) = Resolve-ProjectParameters -Owner $ProjectOwner -ProjectNumber $ProjectNumber

        $sourceItem = Get-BaseProjectItem -Owner $ProjectOwner -ProjectNumber $ProjectNumber -ItemId $ItemId
        $title = $sourceItem.Title
        $body = $sourceItem.Body

        # Create Issue
        $url = New-ProjectIssueDirect -RepoOwner $RepoOwner -RepoName $RepoName -Title $title -Body $body

        if(! $url ){
            "Issue could not be created" | Write-MyError
            return $null
        }

        if(-Not $DoNotAddToProject){
            # Add issue to project
             $itemId = Add-ProjectItem -Owner $ProjectOwner -ProjectNumber $ProjectNumber -Url $url
        }

        if( $OpenOnCreation ) {
            Open-Url $url
        }

        return $itemId
    }
    catch{
        throw "Error creating issue and adding to project: $_"
    }

} Export-ModuleMember -Function Copy-ProjectIssue