Set-MyInvokeCommandAlias -Alias AddSubIssue -Command 'Invoke-AddSubIssue -IssueId {contentid} -SubIssueUrl {subissueurl} -ReplaceParent {replaceparent}'

function Add-ProjectSubIssueDirect {
    [cmdletbinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        # [Parameter(Mandatory)][string]$IssueId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter(Mandatory, Position = 1)][string]$SubIssueUrl,
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