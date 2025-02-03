function New-FieldCO {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet("DATE", "ITERATION", "NUMBER", "SINGLE_SELECT", "TEXT")]
        [string]$DataType,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Value,
        [Parameter(ValueFromPipelineByPropertyName)][string]$SingleSelectOptions,
        [Parameter(ValueFromPipelineByPropertyName)][string]$IterationsConfiguration
    )
    process {
        return @{
            Id = $Id
            Name = $Name
            DataType = $DataType
            Value = $Value
            SingleSelectOptions = $SingleSelectOptions
            IterationsConfiguration = $IterationsConfiguration
        }
    }
}

function Test-FieldCO {
    param (
        [Parameter(ValueFromPipeline)][PSCustomObject]$Field
    )
    if (-not $Field.Id) { return $false }
    if (-not $Field.Name) { return $false }
    if ($Field.DataType -notin @("DATE", "ITERATION", "NUMBER", "SINGLE_SELECT", "TEXT")) { return $false }
    if (-not $Field.Value) { return $false }
    if ($Field.DataType -eq "SINGLE_SELECT" -and -not $Field.SingleSelectOptions) { return $false }
    if ($Field.DataType -eq "ITERATION" -and -not $Field.IterationsConfiguration) { return $false }
    if ($Field.DataType -ne "SINGLE_SELECT" -and $Field.SingleSelectOptions) { return $false }
    if ($Field.DataType -ne "ITERATION" -and $Field.IterationsConfiguration) { return $false }
    return $true
}

function ConvertTo-FieldCO {
    param (
        [Parameter(ValueFromPipeline)][string]$Json
    )
    $field = $Json | ConvertFrom-Json
    if (-not (Test-FieldCO -Field $field)) {
        throw "Invalid FieldCO object"
    }
    return $field
}
