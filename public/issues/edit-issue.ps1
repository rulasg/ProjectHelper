Set-MyInvokeCommandAlias -Alias UpdateIssue -Command 'Invoke-UpdateIssue -IssueId {issueid} -Title "{title}" -Body "{body}"'

function Edit-Issue {
    param(
        [Parameter(Mandatory=$true)][string]$IssueId,
        [Parameter()][string]$Title,
        [Parameter()][string]$Body
    )


    $params = @{
        issueid = $issueId
        title = $Title
        body = $Body
    }

    $response = Invoke-MyCommand -Command UpdateIssue -Parameters $params

    # check if the response is null
    if($response.errors){
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if($response.data.updateIssue.__typename -ne "UpdateIssuePayload" )
    {
        "Issue not updated" | Write-MyError
        return $null
    }

    return $issueId
} Export-ModuleMember -Function Edit-Issue
