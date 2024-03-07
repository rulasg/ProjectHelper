Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFields -Command "Invoke-GitHubOrgProjectWithFields -Owner {owner} -Project {projectnumber}"

function Invoke-GitHubOrgProjectWithFields {
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Project
    )

    $params = @{ owner = $Owner ; projectnumber = $Project }

    $result  = Invoke-MyCommand -Command GitHubOrgProjectWithFields -Parameters $params

    # check for errors

    return $result
} Export-ModuleMember -Function Invoke-GitHubOrgProjectWithFields

function _GitHubProjectFields {
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Project
    )

    # Use the environmentraviable 
    $token = $env:GITHUB_TOKEN
    if(-not $token){
        throw "GITHUB_TOKEN environment variable not set"
    }

    # Define the GraphQL query with variables
    $querypath =  $PSScriptRoot | Join-Path -ChildPath orgprojectwithfields.query
    $query = get-content -path $querypath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    [int]$pn = $Project
    $variables = @{
        login = $Owner
        number = $pn
        afterFields = $null
        afterItems = $null
        firstFields = 30
        firstItems = 100
    }

    # Define the body for the request
    $body = @{
        query = $query
        variables = $variables
    } | ConvertTo-Json

    # Send the request
    # $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers

    $parameters = @{
        body = $body
        headers = $headers
    }

    $response = Invoke-MyCommand -Command OrgProjectWithFields -Parameters $parameters

    # Return the field names
    return $response.data.organization.projectv2
}