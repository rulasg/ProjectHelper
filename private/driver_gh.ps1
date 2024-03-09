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
        mutation= $mutation
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
} Export-ModuleMember -Function Invoke-GitHubUpdateItemValues



# GraphQL variables: {
#     "input": {
#         "projectId": "PVT_kwDOBCrGTM4ActQa",
#         "itemId": "PVTI_lADOBCrGTM4ActQazgMuXXc",
#         "fieldId": "PVTF_lADOBCrGTM4ActQazgSkYm8",
#         "value": {
#             "text": "some text"
#         }
#     }
# }

function Get-GithubToken{
    [CmdletBinding()]
    param()

    $token = Invoke-MyCommand -Command GetToken

    return $token
}