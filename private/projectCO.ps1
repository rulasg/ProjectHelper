function New-ProjectCO {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Title,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][int]$Number,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Owner,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$URL,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Description
    )
    process {
        return @{
            Id = $Id
            Title = $Title
            Description = $Description
            Number = $Number
            Owner = $Owner
            URL = $URL
        }
    }
}

function Test-ProjectCO {
    param (
        [Parameter(ValueFromPipeline)][PSCustomObject]$Project
    )
    if (-not $Project.Id) { return $false }
    if (-not $Project.Title) { return $false }
    if (-not $Project.Number) { return $false }
    if (-not $Project.Owner) { return $false }
    if (-not $Project.URL) { return $false }
    # if (-not $Project.Description) { return $false }
    return $true
}

function ConvertTo-ProjectCO {
    param (
        [Parameter(ValueFromPipeline)][string]$Json
    )
    $project = $Json | ConvertFrom-Json
    if (-not (Test-ProjectCO -Project $project)) {
        throw "Invalid ProjectCO object"
    }
    return $project
}