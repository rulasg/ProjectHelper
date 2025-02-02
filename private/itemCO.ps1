function New-ItemCO {
    <#
    .SYNOPSIS
    Creates a new item with the specified properties.
    
    .PARAMETER Id
    The unique identifier for the item.
    
    .PARAMETER Title
    The title of the item.
    
    .PARAMETER URL
    The URL associated with the item.
    
    .PARAMETER Description
    The description of the item.
    
    .OUTPUTS
    Hashtable representing the new item.
    #>
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Title,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$URL,
        [Parameter(          ValueFromPipelineByPropertyName)][string]$Description
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
    <#
    .SYNOPSIS
    Validates the properties of an item.
    
    .PARAMETER Item
    The hashtable representing the item to be validated.
    
    .OUTPUTS
    Boolean indicating whether the item is valid.
    #>
    param (
        [hashtable]$Item
    )
    if (-not $Item.Id) { return $false }
    if (-not $Item.Title) { return $false }
    if (-not $Item.URL) { return $false }
    return $true
}

function ConvertTo-ItemCO {
    <#
    .SYNOPSIS
    Converts a JSON string to an item hashtable.
    
    .PARAMETER Json
    The JSON string representing the item.
    
    .OUTPUTS
    Hashtable representing the item.
    #>
    param (
        [string]$Json
    )
    return $Json | ConvertFrom-Json
}