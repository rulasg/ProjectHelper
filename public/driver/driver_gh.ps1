Set-MyinvokeCommandAlias -Alias GetToken -Command "gh auth token"


<#
    .SYNOPSIS
    Retrieves a GitHub organization project with fields.

    .DESCRIPTION
    This is an integration function that is not intended to be used directly by the user.
    It fetches project details including fields and items from a GitHub organization project.

    .EXAMPLE
    Invoke-GitHubOrgProjectWithFields -Owner "someOwner" -ProjectNumber 164
#>
function Invoke-GitHubOrgProjectWithFields {
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$ProjectNumber,
        [Parameter()] [string]$Query = "",
        [Parameter()] [string]$afterFields = $null,
        [Parameter()] [int]$firstFields = 100,
        [Parameter()] [string]$afterItems = $null,
        [Parameter()] [int]$firstItems = 100,
        [Parameter()] [int]$lastComments = 1
    )

    # Define the variables for the request
    [int]$pn = $ProjectNumber
    $variables = @{
        login = $Owner
        number = $pn
        afterFields = $afterFields
        afterItems = $afterItems
        firstFields = $firstFields
        firstItems = $firstItems
        lastComments = $lastComments
        query = $query
    }

    # Send the request
    $response = Invoke-GraphQL -Variables $variables -Query (Get-GraphQLString "orgprojectwithfieldsAndItems.query")

    # Return the field names
    return $response
} Export-ModuleMember -Function Invoke-GitHubOrgProjectWithFields

<#
.SYNOPSIS
Invokes a GitHub organization project query

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Retrieves information about a GitHub organization project using GraphQL.
#>
function Invoke-GitHubOrgProject{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$ProjectNumber
    )

    return InvokeGitHubOrgProject -Owner $Owner -ProjectNumber $ProjectNumber -QueryFileName "orgproject.query"
} Export-ModuleMember -Function Invoke-GitHubOrgProject

function InvokeGitHubOrgProject {
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$ProjectNumber,
        [Parameter(Mandatory=$false)] [string]$QueryFileName,
        [Parameter(Mandatory=$false)] [string]$afterFields = $null,
        [Parameter(Mandatory=$false)] [string]$afterItems = $null
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $query =  Get-GraphQLString $QueryFileName



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
        getErrrorString -Errors $response.errors | Write-MyError
        return
    }

    # Return the field names
    return $response
}

<#
.SYNOPSIS
Updates item values in a GitHub project

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Updates the values of specific fields for an item in a GitHub project.
#>
# function Invoke-GitHubUpdateItemValues{
#     param(
#         [Parameter(Mandatory=$true)] [string]$ProjectId,
#         [Parameter(Mandatory=$true)] [string]$ItemId,
#         [Parameter(Mandatory=$true)] [string]$FieldId,
#         [Parameter(Mandatory=$true)] [object]$Value,
#         [Parameter(Mandatory=$true)] [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]
#         [string]$Type
#     )

#     "ProjectId: $ProjectId, ItemId: $ItemId, FieldId: $FieldId, Value: $Value, Type: $Type" | Write-MyDebug -section "driver_gh"

#     # Use the environmentraviable
#     $token = Get-GithubToken
#     if(-not $token){
#         throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
#     }

#     # Define the GraphQL query with variables
#     $mutation = Get-GraphQLString "updateItemValues.mutant"



#     # Define the headers for the request
#     $headers = @{
#         "Authorization" = "Bearer $token"
#         "Content-Type" = "application/json"
#     }

#     # Ensure that if the $type is number the value is a number
#     # API fails if when updaring a number the value type in the Input payload s not a number
#     if($Type -eq "number"){
#         $Value = [decimal]$Value
#     }

#     # Define the variables for the request
#     $variables = @{
#         input = @{
#             projectId = $ProjectId
#             itemId = $ItemId
#             fieldId = $FieldId
#             value = @{
#                 $Type=$Value
#             }
#         }
#     }

#     # Define the body for the request
#     $body = @{
#         query= $mutation
#         variables = $variables
#     } | ConvertTo-Json -Depth 10

#     # Send the request
#     $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post -Body $body -Headers $headers

#     # Check if here are errors
#     if($response.errors){
#         $response.errors | ForEach-Object {
#             getErrrorString -Errors $response.errors | Write-MyError
#         }
#         return $null
#     }

#     # Return the field names
#     return $response
# } Export-ModuleMember -Function Invoke-GitHubUpdateItemValues

function Invoke-GitHubUpdateItemValues{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$ItemId,
        [Parameter(Mandatory=$true)] [string]$FieldId,
        [Parameter(Mandatory=$true)] [object]$Value,
        [Parameter(Mandatory=$true)] [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]
        [string]$Type
    )

    "ProjectId: $ProjectId, ItemId: $ItemId, FieldId: $FieldId, Value: $Value, Type: $Type" | Write-MyDebug -section "driver_gh"

    # Define the GraphQL query with variables
    $mutation = Get-GraphQLString "updateItemValues.mutant"

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

    $response = Invoke-GraphQL -Query $mutation -Variables $variables

    # Return the field names
    return $response
} Export-ModuleMember -Function Invoke-GitHubUpdateItemValues

<#
.SYNOPSIS
Clears item values in a GitHub project

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Clears the values of specific fields for an item in a GitHub project.

.NOTES
Currently only text, number, date, assignees, labels, single-select, iteration and milestone fields are supported.
#>
function Invoke-GitHubClearItemValues{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$ItemId,
        [Parameter(Mandatory=$true)] [string]$FieldId
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $mutation = Get-GraphQLString "clearItemValues.mutant"

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
} Export-ModuleMember -Function Invoke-GitHubClearItemValues

<#
.SYNOPSIS
Gets issue or pull request information

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Retrieves detailed information about an issue or pull request from GitHub.
#>
function Invoke-GetIssueOrPullRequest{
    param(
        [Parameter(Mandatory)] [string] $Url
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $query =  Get-GraphQLString "getIssueOrPullRequest.query"

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
        getErrrorString -Errors $response.errors | Write-MyError
        return
    }

    # Return the field names
    return $response
} Export-ModuleMember -Function Invoke-GetIssueOrPullRequest

<#
.SYNOPSIS
Adds an item to a GitHub project

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Adds a GitHub issue or pull request to a project board.
#>
function Invoke-AddItemToProject{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$ContentId
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $mutation = Get-GraphQLString "addItemToProject.mutant"



    # Define the headers for the request
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the variables for the request
    $variables = @{
        input = @{
            projectId = $ProjectId
            contentId = $ContentId
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
} Export-ModuleMember -Function Invoke-AddItemToProject

<#
.SYNOPSIS
Removes an item from a GitHub project

.DESCRIPTION
This is an integration function that is not intended to be used directly by the user.
Removes a GitHub issue or pull request from a project board.
#>
function Invoke-RemoveItemFromProject{
    param(
        [Parameter(Mandatory=$true)] [string]$ProjectId,
        [Parameter(Mandatory=$true)] [string]$ItemId
    )

    # Use the environmentraviable
    $token = Get-GithubToken
    if(-not $token){
        throw "GH Cli Auth Token not available. Run 'gh auth login' in your terminal."
    }

    # Define the GraphQL query with variables
    $mutation = Get-GraphQLString "removeItemFromProject.mutant"

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
} Export-ModuleMember -Function Invoke-RemoveItemFromProject

function getErrrorString{
    param(
        [Parameter(Mandatory=$true)] [object]$Errors
    )

    $errString = ""
    foreach($err in $Errors){
        $errString += "[$($err.path)] [$($err.type)] $($err.message) ||"
    }
    # remove last ||
    if($errString.EndsWith("||")){
        $errString = $errString.Substring(0, $errString.Length - 2)
    }
    return $errString
}

<#
.SYNOPSIS
Gets a GitHub authentication token

.DESCRIPTION
Retrieves a GitHub authentication token using the GitHub CLI.
#>
function Get-GithubToken{
    [CmdletBinding()]
    param()

    $token = Invoke-MyCommand -Command GetToken

    if(-not $token){
        throw "Token not available. Check `gh auth token` output."
    }

    return $token
}

function Get-GraphQLString{
    param(
        [Parameter(Mandatory, Position = 0)] [string]$FileName
    )

    Write-MyDebug -section "driver_gh" -message "Getting GraphQL string from file: $FileName"

    $path = getmockfilepath -FileName $FileName

    $content = get-content -path $path | Out-String

    $content = Expand-GraphQLString -GraphQLString $content

    return $content
}

function getmockfilepath{
    param(
        [Parameter(Mandatory, Position = 0)] [string]$FileName
    )

    $local = $PSScriptRoot
    $public = $local | Split-Path -Parent

    $path = $public | Join-Path -ChildPath "graphql" -AdditionalChildPath $FileName

    # Verify that the file exists
    if(! (Test-Path -Path $path)){
        throw "GraphQL file not found at path: $path"
    }

    return $path
}

function Expand-GraphQLString{
    param(
        [Parameter(Mandatory, Position = 0)] [string]$GraphQLString
    )

    $tags = [regex]::Matches($GraphQLString,'\{\{(\w+)\}\}') | ForEach-Object { $_.Groups[1].Value }

    # If no tags found, return the original string
    if($tags.Count -eq 0){
        return $GraphQLString
    }

    $content = $GraphQLString

    foreach($tag in $tags){
        $path = getmockfilepath -FileName "_$tag.tag"
        $tagContent = Get-Content -Path $path | Out-String

        $content = $content -replace "\{\{$tag\}\}", $tagContent
    }

    # loop back to expand nested tags
    $ret = Expand-GraphQLString -GraphQLString $content

    return $ret
}