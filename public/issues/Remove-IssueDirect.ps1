
Set-MyInvokeCommandAlias -Alias RemoveIssue -Command 'Invoke-RemoveIssue -IssueId {issueId}'


function Remove-ProjectIssueDirect {
    [CmdletBinding()]
     param(
         [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position = 0)][string]$Url
     )

     process{

         $issue = Get-ProjectIssue -Url $Url
         
         if( ! $issue ){
             throw "Issue with URL $Url not found"
            }
            
            $result = Invoke-MyCommand -Command RemoveIssue -Parameters @{ issueId = $issue.id }
            
            $repoUrl = $result.data.deleteIssue.repository.url
            
            # Check that issue was part of the returned repo url
            if($issue.url.StartsWith($repoUrl)){
                return $issue.url
                # Removed properly
            }
            
            # Issue not removed properly
            throw "Issue with URL $Url not removed properly. Repo URL in response is [$repoUrl]"
        }
 } Export-ModuleMember -Function Remove-ProjectIssueDirect