

function Invoke-FindProject{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter()][string]$Pattern,
        [Parameter()][int]$firstProject = 100,
        [Parameter()][string]$afterProject = $null
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $public = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $qlPath =  $public | Join-Path -ChildPath "graphql" -AdditionalChildPath "findProject.query"
    $mutation = get-content -path $qlPath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        login =$Owner
        pattern = $Pattern -replace '"','""'
        firstProject = $firstProject
        afterProject = $afterProject
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
            "RESPONSE Type[$($_.type)] $($_.message)" | Write-MyError
        }
        return $null
    }

    # Return the field names
    return $response

} Export-ModuleMember -Function Invoke-FindProject