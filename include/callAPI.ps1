
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

    ">>>" | writedebug

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
        "[[QUERY]]" | writedebug
        $Query | writedebug

        "[[VARIABLES]]" | writedebug
        $Variables | ConvertTo-Json -Depth 100 | writedebug

        # Send the request
        $start = Get-Date
        ">>> Invoke-RestMethod - $apiUri" | writedebug
        if([string]::IsNullOrWhiteSpace($OutFile))
             { $response = Invoke-RestMethod -Uri $apiUri -Method Post -Body $body -Headers $headers }
        else { $response = Invoke-RestMethod -Uri $apiUri -Method Post -Body $body -Headers $headers -OutFile $OutFile }
        "<<< Invoke-RestMethod - $apiUri [ $(((Get-Date) - $start).TotalSeconds) seconds]" | writedebug

        # Trace response
        "[[RESPONSE]]" | writedebug
        $response | ConvertTo-Json -Depth 100 | writedebug

        if($response.errors){
            throw "GraphQL query return errors - Error: $($response.errors.message)"
        }

        return $response
    }
    catch {
        "[[THROW]]" | writedebug
        $_.Exception.Message | ConvertTo-Json -Depth 100 | writedebug
        throw New-Object system.Exception("Error calling GraphQL",$_.Exception)

    }
}

function Invoke-RestAPI {
    param(
        [Parameter(Mandatory)][string]$Api,
        [Parameter()][string]$Token,
        [Parameter()] [string]$ApiHost,
        [Parameter()] [string]$PageSize = 30
    )

    ">>>" | writedebug

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
        ">>> Invoke-RestMethod - $url" | writedebug
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ResponseHeadersVariable responseHeaders

        $responseHeaders | writedebug

        # Process paging
        if($responseHeaders.link){$paging=$true}
        while ($paging) {
            $links = $responseHeaders.link -split ',\s*'

            # Find the link with rel="next"
            $nextLink = $links | Where-Object { $_ -match 'rel="next"' }
            $nextUrl = $nextLink -match '<([^>]+)>; rel="next"'

            if($nextUrl){
                $nextUrl = $matches[1]
                ">>> Invoke-RestMethod - $nextUrl" | writedebug
                $nextResponse = Invoke-RestMethod -Uri $nextUrl -Method Get -Headers $headers -ResponseHeadersVariable responseHeaders
                $response += $nextResponse
                $paging = $null -ne $responseHeaders.link
            } else {
                $paging = $false
            }
        }

        "<<< Invoke-RestMethod - $url [ $(((Get-Date) - $start).TotalSeconds) seconds]" | writedebug

        # Trace response
        "[[RESPONSE]]" | writedebug
        $response | ConvertTo-Json -Depth 100 | writedebug


        return $response
    }
    catch {
        throw
    }
}

####################################################################################################

$ENV_VAR_HOST_NAME = "GH_HOST"
$DEFAULT_GH_HOST = "github.com"

function Get-ApiHost {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$ApiHost
    )

    if(![string]::IsNullOrWhiteSpace($ApiHost)){
        "ApiHost provided" | writedebug
        return $ApiHost
    }

    $envValue = Get-EnvVariable -Name $ENV_VAR_HOST_NAME
    if(![string]::IsNullOrWhiteSpace($envValue)){
        "Host from env $envValue" | writedebug
        return $envValue
    }

    "Default host $DEFAULT_GH_HOST" | writedebug
    return $DEFAULT_GH_HOST
}


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
        "Token from env" | writedebug
        return $envValue
    }

    $params = @{
        host = $ApiHost
    }

    "Token from GetToken for host [$ApiHost]" | writedebug
    $result = Invoke-MyCommand -Command "GetToken" -Parameters $params

    if(-Not $result){
        throw "No Api token found"
    }

    return $result
}

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

####################################################################################################

function writedebug{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][string]$Message
    )

    process{
        Write-MyDebug $Message -Section "api"
    }
}
