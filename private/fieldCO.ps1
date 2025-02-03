function New-FieldCO {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Type,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Value,
        [Parameter(ValueFromPipelineByPropertyName)][string]$SingleSelectOptions,
        [Parameter(ValueFromPipelineByPropertyName)][string]$IterationsConfiguration
    )
    process {
        return @{
            Id = $Id
            Name = $Name
            Type = $Type
            Value = $Value
            SingleSelectOptions = $SingleSelectOptions
            IterationsConfiguration = $IterationsConfiguration
        }
    }
}

function Test-FieldCO {
    param (
        [hashtable]$Field
    )
    if (-not $Field.Id) { return $false }
    if (-not $Field.Name) { return $false }
    if (-not $Field.Type) { return $false }
    if (-not $Field.Value) { return $false }
    if ($Field.Type -eq "SINGLE_SELECT" -and -not $Field.SingleSelectOptions) { return $false }
    if ($Field.Type -eq "ITERATION" -and -not $Field.IterationsConfiguration) { return $false }
    return $true
}

function ConvertTo-FieldCO {
    param (
        [string]$Json
    )
    return $Json | ConvertFrom-Json
}
