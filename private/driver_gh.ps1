Set-MyinvokeCommandAlias -Alias GetToken -Command "gh auth token"

<#
    .SYNOPSIS
    This function retrieves a GitHub organization project with fields.

    .EXAMPLE
    Invoke-GitHubOrgProjectWithFields -Owner "someOwner" -Project 164
#>
function Invoke-GitHubOrgProjectWithFields {
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$ProjectNumber
    )

    # Use the environmentraviable 
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
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
    [int]$pn = $ProjectNumber
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
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers

    # Check if here are errors
    if($response.errors){
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return
    }

    # Return the field names
    return $response.data.organization.projectv2
} Export-ModuleMember -Function Invoke-GitHubOrgProjectWithFields

function Get-GithubToken{
    [CmdletBinding()]
    param()

    $token = Invoke-MyCommand -Command GetToken

    return $token
}