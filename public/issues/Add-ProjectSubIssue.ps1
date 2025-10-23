Set-MyInvokeCommandAlias -Alias AddSubIssue -Command 'Invoke-AddSubIssue -IssueId {contentid} -SubIssueUrl {subissueurl} -ReplaceParent {replaceparent}'

function Add-ProjectSubIssueDirect {
    [cmdletbinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$IssueId,
        [Parameter(Mandatory)][string]$SubIssueUrl,
        [Parameter()][switch]$ReplaceParent
    )

    $Owner, $ProjectNumber = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ throw "Owner and ProjectNumber are required"}

    # Get Parent Issue
    $parent = Get-ProjectItem -ItemId $IssueId -Owner $Owner -ProjectNumber $ProjectNumber
    if( ! $parent ){
        "Parent IssueId [$IssueId] not found on project $Owner/$ProjectNumber" | Write-MyError
        return $null
    }

    # Check if Subissue already has parent

    $parameters = @{
        contentid = $parent.contentId
        subissueurl = $SubIssueUrl
        replaceparent = $ReplaceParent.IsPresent
        # replaceparent = $false
    }

    try{
        $response = Invoke-MyCommand -Command AddSubIssue -Parameters $parameters
    } catch {
        $errorMessage = $_.Exception.Message
        "Failed to add SubIssue [$SubIssueUrl] to IssueId [$IssueId] - $errorMessage" | Write-MyError
        return $null
    }
    # Call

    # check for errors
    $responseParentId = $response.data.addSubIssue.issue.id
    $responseSubIssueId = $response.data.addSubIssue.subIssue.id

    if( $null -eq $responseParentId -or $null -eq $responseSubIssueId ){
        "Failed to add SubIssue [$SubIssueUrl] to IssueId [$IssueId]" | Write-MyError
        return $null
    }

    return $true


} Export-ModuleMember -Function Add-ProjectSubIssueDirect
