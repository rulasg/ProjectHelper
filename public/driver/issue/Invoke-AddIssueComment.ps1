function Invoke-AddIssueComment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$SubjectId,
        [Parameter(Mandatory = $true)][string]$Comment
    )

    # Use the environmentraviable 
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $moduleroot = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $qlPath =  $moduleroot | Join-Path -ChildPath "graphql" -AdditionalChildPath "commentCreate.mutant"
    $query = get-content -path $qlPath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        input = @{
            subjectId = $SubjectId
            body = $Comment
        }
    }

    # Define the body for the request
    $body = @{
        query= $query
        variables = $variables
    } | ConvertTo-Json -Depth 10

    # Send the request
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers

    # Check if here are errors
    if($response.errors){
        $response.errors | ForEach-Object {
            "RESPONSE Type[$($_.type)] $($_.message)" | Write-MyError
        }
        return $null
    }

    # Return the field names
    return $response
} Export-ModuleMember -Function Invoke-AddIssueComment

# GraphQL query:
# mutation CommentCreate($input:AddCommentInput!){addComment(input: $input){commentEdge{node{url}}}}
# GraphQL variables: {"input":{"subjectId":"I_kwDOIEf6YM7NZPEl","body":"sample comment 1"}}