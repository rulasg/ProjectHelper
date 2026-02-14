Set-MyInvokeCommandAlias -Alias AddSubIssue -Command 'Invoke-AddSubIssue -IssueId {contentid} -SubIssueUrl {subissueurl} -ReplaceParent {replaceparent}'

function Add-ProjectSubIssueDirect {
    [cmdletbinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        # [Parameter(Mandatory)][string]$IssueId,
        [Parameter(Mandatory, Position = 0)][string]$ItemId,
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][Alias("url")][string]$SubIssueUrl,
        [Parameter()][switch]$ReplaceParent
    )

    $Owner, $ProjectNumber = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ throw "Owner and ProjectNumber are required"}

    # Get Parent Issue
    $parent = Get-ProjectItem -ItemId $ItemId -Owner $Owner -ProjectNumber $ProjectNumber
    if( ! $parent ){
        "Parent ItemId [$ItemId] not found on project $Owner/$ProjectNumber" | Write-MyError
        return $null
    }

    # Check if Subissue already has parent

    $parameters = @{
        contentid = $parent.contentId
        subissueurl = $SubIssueUrl
        replaceparent = $ReplaceParent.IsPresent
        # replaceparent = $false
    }

    # Call API
    try{
        $response = Invoke-MyCommand -Command AddSubIssue -Parameters $parameters
    } catch {
        $errorMessage = $_.Exception.Message
        "Failed to add SubIssue [$SubIssueUrl] to ItemId [$ItemId] - $errorMessage" | Write-MyError
        return $null
    }

    # check for errors
    $responseParentId = $response.data.addSubIssue.issue.id
    $responseSubIssueId = $response.data.addSubIssue.subIssue.id

    if( $null -eq $responseParentId -or $null -eq $responseSubIssueId ){
        "Failed to add SubIssue [$SubIssueUrl] to ItemId [$ItemId]" | Write-MyError
        return $null
    }

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Add subissue to parent
    addSubIssue -Item $parent -SubIssue $response.data.addSubIssue.subIssue

    Set-Item $db $parent
    Save-ProjectDatabaseSafe -Database $db

    return $true

} Export-ModuleMember -Function Add-ProjectSubIssueDirect


function Add-ProjectSubissueCreate {
    [CmdletBinding()]
    [Alias("New-Issue")]
    param (
        [Parameter(Mandatory, Position = 0)][string]$ItemId,
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
    $ProjectOwner,$ProjectNumber = Get-OwnerAndProjectNumber -Owner $ProjectOwner -ProjectNumber $ProjectNumber
    $item = Get-ProjectItem -ItemId $ItemId -Owner $ProjectOwner -ProjectNumber $ProjectNumber
    if($null -eq $Item){
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

    $url = New-ProjectIssueDirect @params
    Write-Host $url

    $params = @{
        Owner = $ProjectOwner
        ProjectNumber = $ProjectNumber
        SubIssueUrl = $url
        ItemId = $ItemId
    }
    $result = Add-ProjectSubIssueDirect @params
    if($result)
        { Write-MyHost "SubIssue added successfully" }
        else {Write-MyError "Failed to add SubIssue" ; return}

    # Add to project
    if($AddToProject){
        $subissueId = Add-ProjectItem -Url $url -Owner $ProjectOwner -ProjectNumber $ProjectNumber
        Write-Host $subissueId
    }

    # Open
    if($OpenOnCreation){
        Open-Url -Url $url
    }

} Export-ModuleMember -Function Add-ProjectSubissueCreate


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