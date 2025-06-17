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
        [Parameter(Mandatory=$true)] [string]$ProjectNumber,
        [Parameter(Mandatory=$false)] [string]$afterFields = $null,
        [Parameter(Mandatory=$false)] [string]$afterItems = $null
    )

    # Use the environmentraviable 
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $qlPath =  $PSScriptRoot | Join-Path -ChildPath "graphql" -AdditionalChildPath "orgprojectwithfields.query"
    $query = get-content -path $qlPath | Out-String

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
        afterFields = $afterFields
        afterItems = $afterItems
        firstFields = 100
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
    return $response
} Export-ModuleMember -Function Invoke-GitHubOrgProjectWithFields

function Invoke-GitHubUpdateItemValues{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$ItemId,
        [Parameter(Mandatory=$true)] [string]$FieldId,
        [Parameter(Mandatory=$true)] [object]$Value,
        [Parameter(Mandatory=$true)] [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]
        [string]$Type
    )

    # Use the environmentraviable 
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $qlPath =  $PSScriptRoot | Join-Path -ChildPath "graphql" -AdditionalChildPath "updateItemValues.mutant"
    $mutation = get-content -path $qlPath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Ensure that if the $type is number the value is a number
    # API fails if when updaring a number the value type in the Input payload s not a number
    if($Type -eq "number"){
        $Value = [decimal]$Value
    }

    # Define the variables for the request
    $variables = @{
        input = @{
            projectId = $ProjectId
            itemId = $ItemId
            fieldId = $FieldId
            value = @{
                $Type=$Value
            }
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
        $response.errors | foreach {
            "RESPONSE Type[$($_.type)] $($_.message)" | Write-MyError
        }
        return $null
    }

    # Return the field names
    return $response
} Export-ModuleMember -Function Invoke-GitHubUpdateItemValues

function Invoke-GetIssueOrPullRequest {
    param(
        [Parameter(Mandatory)] [string] $Url
    )

    # Use the environmentraviable 
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $qlPath =  $PSScriptRoot | Join-Path -ChildPath "graphql" -AdditionalChildPath "getIssueOrPullRequest.query"
    $query = get-content -path $qlPath | Out-String

    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        url = $Url
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
    return $response
} Export-ModuleMember -Function Invoke-GetIssueOrPullRequest

function Get-GithubToken{
    [CmdletBinding()]
    param()

    $token = Invoke-MyCommand -Command GetToken

    return $token
}