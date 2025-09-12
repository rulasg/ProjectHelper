
function Invoke-UpdatePullRequest{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
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
    $qlPath =  $public | Join-Path -ChildPath "graphql" -AdditionalChildPath "updatePullRequest.mutant"
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
        "No content to update. Skip update for $Id." | Write-Verbose
        return $null
    }

    # Add the pull request id to the variables
    $variables.input.pullRequestId = $Id

    # Define the body for the request
    $body = @{
        query= $mutation
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

} Export-ModuleMember -Function Invoke-UpdatePullRequest