
Set-MyInvokeCommandAlias -Alias RemoveIssue -Command 'Invoke-RemoveIssue -IssueId {issueId}'


function Remove-IssueDirect {
    [CmdletBinding()]
     param(
         [Parameter(Position = 0)][string]$Url
     )
 
     $issue = Get-ProjectIssue -Url $Url
 
    if( ! $issue ){
        throw "Issue with URL $Url not found"
    }

    $result = Invoke-MyCommand -Command RemoveIssue -Parameters @{ issueId = $issue.id }

    $repoUrl = $result.data.deleteIssue.repository.url

     # Verify response value
    if($issue.repository -ne $repoUrl){
        throw "Issue not removed properly"
    }

     return $true

 }