
# INCLUDE CALL API
#
# This module provides functions to call the GitHub API
#

function Invoke-GraphQL {
    param(
        [Parameter(Mandatory=$true)] [string]$Query,
        [Parameter(Mandatory=$true)] [object]$Variables,
        [Parameter()] [string]$Token,
        [Parameter()] [string]$ApiHost,
        [Parameter()] [string]$OutFile
    )

    ">>>" | Write-MyVerbose

    $ApiHost = Get-ApiHost -ApiHost:$ApiHost
    $token = Get-ApiToken -Token:$Token -ApiHost:$ApiHost

    try {
        $apiUri = "https://api.$ApiHost/graphql"
    
        # Define the headers for the request
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
            "GraphQL-Features" = $GRAPHQL_FEATURES
        }
    
        # Define the body for the request
        $body = @{
            query = $Query
            variables = $Variables
        } | ConvertTo-Json -Depth 100
    
        # Trace request
        "[[QUERY]]" | Write-MyVerbose
        $Query | Write-MyVerbose
    
        "[[VARIABLES]]" | Write-MyVerbose
        $Variables | ConvertTo-Json -Depth 100 | Write-MyVerbose
    
        # Send the request
        $start = Get-Date
        ">>> Invoke-RestMethod - $apiUri" | Write-MyVerbose
        $response = Invoke-RestMethod -Uri $apiUri -Method Post -Body $body -Headers $headers -OutFile $OutFile
        "<<< Invoke-RestMethod - $apiUri [ $(((Get-Date) - $start).TotalSeconds) seconds]" | Write-MyVerbose
    
        # Trace response
        "[[RESPONSE]]" | Write-MyVerbose
        $response | ConvertTo-Json -Depth 100 | Write-MyVerbose
    
        if($response.errors){
            throw "GraphQL query return errors - Error: $($response.errors.message)"
        }
    
        return $response
    }
    catch {
        throw New-Object system.Exception("Error calling GraphQL",$_.Exception)

    }
} Export-ModuleMember -Function Invoke-GraphQL

function Invoke-RestAPI {
    param(
        [Parameter(Mandatory)][string]$Api,
        [Parameter()][string]$Token,
        [Parameter()] [string]$ApiHost,
        [Parameter()] [string]$PageSize = 30
    )

    ">>>" | Write-MyVerbose

    $ApiHost = Get-ApiHost -ApiHost "$ApiHost"
    $token = Get-ApiToken -ApiHost "$ApiHost"

    try {
        $apiHost = "api.$ApiHost"
    
        # Define the headers for the request
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
    
        $uriBuilder = New-Object System.UriBuilder
        $uriBuilder.Scheme = "https"
        $uriBuilder.Host = $apiHost
        $uriBuilder.Path = $api
        $uriBuilder.Query = "?per_page=$PageSize"
    
        $url = $uriBuilder.Uri.AbsoluteUri
    
        # Send the request
        $start = Get-Date
        ">>> Invoke-RestMethod - $url" | Write-MyVerbose
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ResponseHeadersVariable responseHeaders

        $responseHeaders | Write-MyVerbose

        # Process paging
        if($responseHeaders.link){$paging=$true}
        while ($paging) {
            $links = $responseHeaders.link -split ',\s*'

            # Find the link with rel="next"
            $nextLink = $links | Where-Object { $_ -match 'rel="next"' }
            $nextUrl = $nextLink -match '<([^>]+)>; rel="next"'

            if($nextUrl){
                $nextUrl = $matches[1]
                ">>> Invoke-RestMethod - $nextUrl" | Write-MyVerbose
                $nextResponse = Invoke-RestMethod -Uri $nextUrl -Method Get -Headers $headers -ResponseHeadersVariable responseHeaders
                $response += $nextResponse
                $paging = $null -ne $responseHeaders.link
            } else {
                $paging = $false
            }
        }

        "<<< Invoke-RestMethod - $url [ $(((Get-Date) - $start).TotalSeconds) seconds]" | Write-MyVerbose
    
        # Trace response
        "[[RESPONSE]]" | Write-MyVerbose
        $response | ConvertTo-Json -Depth 100 | Write-MyVerbose


        return $response
    }
    catch {
        throw
    }
} Export-ModuleMember -Function Invoke-RestAPI

####################################################################################################

$ENV_VAR_HOST_NAME = "GH_HOST"
$DEFAULT_GH_HOST = "github.com"

function Get-ApiHost {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$ApiHost
    )

    if(![string]::IsNullOrWhiteSpace($ApiHost)){
        "ApiHost provided" | Write-MyVerbose
        return $ApiHost
    }

    $envValue = Get-EnvVariable -Name $ENV_VAR_HOST_NAME
    if(![string]::IsNullOrWhiteSpace($envValue)){
        "Host from env $envValue" | Write-MyVerbose
        return $envValue
    }

    "Default host $DEFAULT_GH_HOST" | Write-MyVerbose
    return $DEFAULT_GH_HOST
} Export-ModuleMember -Function Get-ApiHost


####################################################################################################


$ENV_VAR_TOKEN_NAME = "GH_TOKEN"

Set-MyInvokeCommandAlias -Alias GetToken -Command "gh auth token -h {host}"

function Get-ApiToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApiHost,
        [Parameter()] [string]$Token
    )

    if(![string]::IsNullOrWhiteSpace($Token)){
        "Token provided" | Write-TraceApi
        return $Token
    }

    $envValue = Get-EnvVariable -Name $ENV_VAR_TOKEN_NAME
    if(![string]::IsNullOrWhiteSpace($envValue)){
        "Token from env" | Write-MyVerbose
        return $envValue
    }

    $params = @{
        host = $ApiHost
    }

    "Token from GetToken for host [$ApiHost]" | Write-MyVerbose
    $result = Invoke-MyCommand -Command "GetToken" -Parameters $params

    if(-Not $result){
        throw "No Api token found"
    }

    return $result
} Export-ModuleMember -Function Get-ApiToken

####################################################################################################

function Get-EnvVariable{
    param(
        [Parameter(Mandatory)][string]$Name
    )

    if(! (Test-Path -Path "Env:$Name") ){
        return $null
    }

    $ret = "Env:$Name"

    return $ret
}

