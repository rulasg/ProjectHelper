<#
Reference: https://docs.github.com/en/graphql/reference/input-objects#updateissueinput

| Name                      | Description                                                   |
| ------------------------- | ------------------------------------------------------------- |
| assigneeIds ([ID!])       | An array of Node IDs of users for this issue.                 |
| body (String)             | The body for the issue description.                           |
| clientMutationId (String) | A unique identifier for the client performing the mutation.   |
| id (ID!)                  | The ID of the Issue to modify.                                |
| issueTypeId (ID)          | The ID of the Issue Type for this issue.                      |
| labelIds ([ID!])          | An array of Node IDs of labels for this issue.                |
| milestoneId (ID)          | The Node ID of the milestone for this issue.                  |
| projectIds ([ID!])        | An array of Node IDs for projects associated with this issue. |
| state (IssueState)        | The desired issue state.                                      |
| title (String)            | The title for the issue.                                      |
#>
function Invoke-UpdateIssue{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$IssueId,
        [Parameter()][string]$Title,
        [Parameter()][string]$Body
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $public = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $qlPath =  $public | Join-Path -ChildPath "graphql" -AdditionalChildPath "updateIssue.mutant"
    $mutation = get-content -path $qlPath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        input = @{}
    }

    # Title can not be empty
    if(-not [string]::IsNullOrWhiteSpace($Title)){
        $variables.input.title = $Title
    }

    # This will avoid to empty the body
    if(-not [string]::IsNullOrWhiteSpace($Body)){
        $variables.input.body = $Body
    }

    # Check if variables are is empty
    if($Variables.input.Count -eq 0){
        "No content to update. Skip update for $IssueId." | Write-Verbose
        return $null
    }

    # Add the issue id to the variables
    $variables.input.id = $IssueId

    # Define the body for the request
    $body = @{
        query= $mutation
        variables = $variables
    } | ConvertTo-Json -Depth 10

    # Send the request
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers

    # Check if here are errors
    if($response.errors){
        $response.errors | foreach {
            "RESPONSE Type[$($_.type)] $($_.message)" | Write-MyError
        }
        return $null
    }

    # Return the field names
    return $response

} Export-ModuleMember -Function Invoke-UpdateIssue