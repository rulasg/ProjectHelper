Set-MyInvokeCommandAlias -Alias AddSubIssue -Command 'Invoke-AddSubIssue -IssueId {contentid} -SubIssueUrl {subissueurl} -ReplaceParent {replaceparent}'

function Add-ProjectSubIssueDirect {
    [cmdletbinding()]
    [Alias("apsid")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 1)][string]$ParentItemId,
        [Parameter(Mandatory, Position = 0)][string]$SubIssueIdOrUrl,
        [Parameter()][switch]$ReplaceParent
    )

    ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    # Resolve to URL from id or Url parameter
    $subIssueItem = Resolve-ItemParameter -Owner $Owner -ProjectNumber $ProjectNumber -IdOrUrl $SubIssueIdOrUrl
    if(-not $subIssueItem){
        "SubIssue Identifier [$SubIssueIdOrUrl] could not be resolved. Using parameter value." | Write-MyDebug -section 'Add-ProjectSubIssueDirect'
        $subIssueItemUrl = $SubIssueIdOrUrl
    } else {
        $subIssueItemUrl = $subIssueItem.url
    }

    $ParentItemId = [string]::IsNullOrWhiteSpace($ParentItemId) ? $(Invoke-QQ_Get_G) : $ParentItemId

    # Get Parent Issue
    $parent = Get-BaseProjectItem -ItemId $ParentItemId -Owner $Owner -ProjectNumber $ProjectNumber
    if( ! $parent ){
        "Parent ItemId [$ParentItemId] not found on project $Owner/$ProjectNumber" | Write-MyError
        return $null
    }

    # Check if Subissue already has parent

    $parameters = @{
        contentid = $parent.contentId
        subissueurl = $subIssueItemUrl
        replaceparent = $ReplaceParent.IsPresent
        # replaceparent = $false
    }

    # Call API
    try{
        $response = Invoke-MyCommand -Command AddSubIssue -Parameters $parameters
    } catch {
        $errorMessage = $_.Exception.Message
        "Failed to add SubIssue [$subIssueItemUrl] to ItemId [$ParentItemId] - $errorMessage" | Write-MyError
        return $null
    }

    # check for errors
    $responseParentId = $response.data.addSubIssue.issue.id
    $responseSubIssueId = $response.data.addSubIssue.subIssue.id

    if( $null -eq $responseParentId -or $null -eq $responseSubIssueId ){
        "Failed to add SubIssue [$subIssueItemUrl] to ItemId [$ParentItemId]" | Write-MyError
        return $null
    }

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Add subissue to parent
    addSubIssue -Item $parent -SubIssue $response.data.addSubIssue.subIssue

    Set-Item $db $parent
    Save-ProjectDatabaseSafe -Database $db

    return $true

} Export-ModuleMember -Function Add-ProjectSubIssueDirect -Alias "apsid"


function Add-ProjectSubissueCreate {
    [CmdletBinding()]
    [Alias("apisc")]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][Alias("Id")][string]$ItemId,

        [Parameter(Position = 1)][string]$RepoOwner,
        [Parameter(Position = 2)][string]$RepoName,
        [Parameter(Mandatory, Position = 3)][string]$Title,
        [Parameter(Position = 4)][string]$Body,
        
        [Parameter()][string]$ProjectOwner,
        [Parameter()][string]$ProjectNumber,

        [Parameter()][switch]$OpenOnCreation,
        [Parameter()][switch]$AddToProject
    )

    # Get Parent item
    ($ProjectOwner,$ProjectNumber) = Resolve-ProjectParameters -Owner $ProjectOwner -ProjectNumber $ProjectNumber

    $ItemId = [string]::IsNullOrWhiteSpace($ItemId) ? $(Invoke-QQ_Get_G) : $ItemId

    $item = Get-BaseProjectItem -ItemId $ItemId -Owner $ProjectOwner -ProjectNumber $ProjectNumber
    if($null -eq $item){
        Write-MyError "Parent ItemId [$ItemId] not found on project $ProjectOwner/$ProjectNumber"
        return
    }

    # resolve the repo
    $repoO = ( [string]::IsNullOrWhiteSpace($RepoOwner) ) ? $item.RepositoryOwner : $RepoOwner
    $repoN = ( [string]::IsNullOrWhiteSpace($RepoName) ) ? $item.RepositoryName : $RepoName

    if([string]::IsNullOrWhiteSpace($repoO) -or [string]::IsNullOrWhiteSpace($repoN)){
        Write-MyError "Repository owner and name are required"
        return
    }

    #
    $repo = Get-Repository -Owner $repoO -Name $repoN

    if( ! $repo ) {
        "Repository $repoO/$repoN not found" | Write-MyError
        return $null
    }

    $params = @{
        RepoName = $repoN
        RepoOwner = $repoO
        Title = $Title
        Body = $Body
    }

    # Create Issue
    $url = New-ProjectIssueDirect @params

    # Link issue to issue as subissue
    $params = @{
        Owner = $ProjectOwner
        ProjectNumber = $ProjectNumber
        SubIssueUrl = $url
        ItemId = $ItemId
    }
    $result = Add-ProjectSubIssueDirect @params
    if(-not $result){
        Write-MyError "Failed to add SubIssue"
        return
    }

    # Add to project
    if($AddToProject){
        $subissueId = Add-ProjectItem -Url $url -Owner $ProjectOwner -ProjectNumber $ProjectNumber
        $ret = $subissueId
    } else {
        $ret = $url
    }

    # Open
    if($OpenOnCreation){
        Open-Url -Url $url
    }

    return $ret

} Export-ModuleMember -Function Add-ProjectSubissueCreate -Alias 'apisc'


function addSubIssue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][object]$Item,
        [Parameter(Mandatory)][object]$SubIssue
    )
    if($null -eq $item.subIssues){
        $item.subIssues = @()
    }

    $item.subIssues += $SubIssue

}