Set-MyInvokeCommandAlias -Alias GetProjectItems -Command 'gh project item-list {projectnumber} --owner {owner} --format json'
Set-MyInvokeCommandAlias -Alias GetProjectFields -Command 'gh project field-list {projectnumber} --owner {owner} --format json'

function Get-ItemsList {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }

    # Items
    $result  = Invoke-MyCommandJsonAsync -Command GetProjectItems -Parameters $params

    # check for errors

    return $result.Items
}

function Get-FieldList {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }

    # Fields
    $result  = Invoke-MyCommandJsonAsync -Command GetProjectFields -Parameters $params

    # check for errors

    return $result.Fields
} Export-ModuleMember -Function Get-FieldList

function _GitHubProjectFields {
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Project
    )

    if($script:Mock_GitHubProjectFields_ContentFile){
        $result = Invoke-Mock_GitHubProjectFields
        return $result.data.organization.projectv2
    }

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
} Export-ModuleMember -Function _GitHubProjectFields

#######################################

$script:Mock_GitHubProjectFields_ContentFile = $null

function Invoke-Mock_GitHubProjectFields{
    [CmdletBinding()]
    param()

    $json = $script:Mock_GitHubProjectFields_ContentFile
    $ret = $json | ConvertFrom-Json -Depth 100

    return $ret
}
function Set-Mock_GitHubProjectFields{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Content
    )

    $script:Mock_GitHubProjectFields_ContentFile = $content

} Export-ModuleMember -Function Set-Mock_GitHubProjectFields

function Reset-Mock_GitHubProjectFields{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Content
    )

    $script:Mock_GitHubProjectFields_ContentFile = $null

} Export-ModuleMember -Function Reset-Mock_GitHubProjectFields