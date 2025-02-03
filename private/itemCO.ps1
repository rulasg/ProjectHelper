function New-ItemCO {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Title,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$URL,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Description
    )
    process {
        return @{
            Id = $Id
            Title = $Title
            URL = $URL
            Description = $Description
        }
    }
}

function Test-ItemCO {
    param (
        [Parameter(ValueFromPipeline)][PSCustomObject]$Item
    )
    if (-not $Item.Id) { return $false }
    if (-not $Item.Title) { return $false }
    if (-not $Item.URL) { return $false }
    return $true
}

function ConvertTo-ItemCO {
    param (
        [Parameter(ValueFromPipeline)][string]$Json
    )
    $item = $Json | ConvertFrom-Json
    if (-not (Test-ItemCO -Item $item)) {
        throw "Invalid ItemCO object"
    }
    return $item
}