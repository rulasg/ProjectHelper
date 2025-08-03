<#
.SYNOPSIS
Finds projects in a GitHub organization

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Searches for projects in a GitHub organization based on a pattern.

.PARAMETER Owner
The GitHub organization that owns the projects

.PARAMETER Pattern
The search pattern to filter projects

.PARAMETER firstProject
The number of projects to return (default: 100)

.PARAMETER afterProject
The cursor to start retrieving projects from (for pagination)
#>
function Invoke-FindProject{
    <#
    .SYNOPSIS
        Finds GitHub projects for a specified organization owner.

    .DESCRIPTION
        Uses the GitHub GraphQL API to search for projects matching a given pattern within an organization.
        This is an integration function not intended for direct user use.

    .PARAMETER Owner
        The GitHub organization name to search within.

    .PARAMETER Pattern
        Optional pattern to filter projects by name.

    .PARAMETER firstProject
        Number of projects to return in a single request. Default is 100.

    .PARAMETER afterProject
        Pagination cursor for subsequent requests. Default is null.

    .OUTPUTS
        Returns the GraphQL response object containing project information or null if an error occurs.

    .NOTES
        This function requires GitHub authentication via the gh CLI.
    #>
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