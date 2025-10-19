function Invoke-CreateDraftItem{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$Title,
        [Parameter(Mandatory=$false)] [string]$Body
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $mutation = Get-GraphQLString "createDraftItem.mutant"

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        input = @{
            projectId = $ProjectId
            title = $Title
            body = $Body
        }
    }

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
            getErrrorString -Errors $response.errors | Write-MyError
        }
        return $null
    }

    # Return the field names
    return $response

} Export-ModuleMember -Function Invoke-CreateDraftItem