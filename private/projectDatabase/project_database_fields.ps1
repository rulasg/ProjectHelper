
function Get-Field{
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$FieldName
    )

    $field = $Database.fields.Values | Where-Object { $_.name -eq $FieldName }

    return $field
}

function Test-FieldValue{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 1)][object]$Field,
        [Parameter(Position = 2)][string]$Value
    )
    $dataType = $Field.dataType

    if([string]::IsNullOrEmpty($Value)){
        # If the value is null or empty, we assume it is a valid value as a no value
        return $true
    }

    switch ($dataType) {
        "NUMBER"         { $ret = $Value | Test-NumberFormat               ;Break }
        "DATE"           { $ret = $Value | Test-DateFormat                 ;Break }
        "SINGLE_SELECT"  { $ret = $Value | Test-SingleSelect -Field $Field ;Break }

        # default to true as any string or null is valid
        default          { $ret = $true }
    }

    if(-not $ret){
        "not valid value [$Value] for field [$($Field.name)] with type [$($Field.dataType)]" | Write-Verbose
    }

    return $ret
}

function ConvertTo-FieldValue{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object]$Field,
        [Parameter(Position = 1)][string]$Value
    )

    $dataType = $Field.dataType

    switch ($dataType) {
        "NUMBER"         { $ret = $value | ConvertTo-Number                 ;Break}
        "SINGLE_SELECT"  { $ret = $value | ConvertTo-SingleSelect $Field    ;Break}

        # default no transformation needed
        default          { $ret = $value }
    }

    return $ret
}

function ConvertFrom-FieldValue{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object]$Field,
        [Parameter(Position = 1)][string]$Value
    )

    $dataType = $Field.dataType

    switch ($dataType) {
        "SINGLE_SELECT"  { $ret = $value| ConvertFrom-SingleSelect -Field $Field ;Break}

        # Default no transformation needed
        default          { $ret = $value }
    }

    return $ret
}

<#.SYNOPSIS
    Convert from OptionId to OptionName
#>
function ConvertFrom-SingleSelect{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object]$Field,
        [Parameter(ValueFromPipeline)][string]$Value
    )
    process{

        if([string]::IsNullOrEmpty($Value)){
            return $null
        }

        $ret = $Field.options.Keys | Where-Object {$Field.options.$_ -eq $value}

        if($null -eq $ret){
            throw "Invalid SingleSelect value [$Value] for field [$($Field.name)] with type [$($Field.dataType)]"
        }

        return $ret
    }
}

<#.SYNOPSIS
    Convert from OptionName to OptionId
#>
function ConvertTo-SingleSelect{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object]$Field,
        [Parameter(ValueFromPipeline)][string]$Value
    )
    process{
        $ret = $Field.options.$Value
        return $ret
    }
}

function Test-SingleSelect{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Value,
        [Parameter(Position = 1)][object]$Field
    )

    process{

        try{
            $result = ConvertTo-SingleSelect -Field $Field -Value $Value

            if($null -eq $result){
                return $false
            }

            return $true
        }
        catch {
            return $false
        }
    }
}

# function Test-DateFormat what will test strings with the date format YYYY-MM-DD
function Test-DateFormat{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Date
    )

    process{

        try {
            $null = [datetime]::ParseExact($Date, 'yyyy-MM-dd', $null)
            
            return $true
        }
        catch {
            return $false
        }
    }
}

function Test-SingleSelectFormat{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Value,
        [Parameter(Position = 1)][object]$Field
    )

    process{
        }

}

function Test-NumberFormat{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Number
    )

    process{

        if([string]::IsNullOrEmpty($Number)){
            # If the number is null or empty, we assume it is a valid value
            return $true
        }

        return $null -ne $(Get-NumberFormatCulture $Number)
    }
}

function ConvertTo-Number {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline)][string]$Value
    )
    process {
        $regex = [regex]"^[^\d-]*(-?(?:\d|(?<=\d)\.(?=\d{3}))+(?:,\d+)?|-?(?:\d|(?<=\d),(?=\d{3}))+(?:\.\d+)?)[^\d]*$"

        # Get the numeric part from the string
        $match = $regex.Match($Value)
        $numberPart = $match.Groups[1].Value

        # Try to guess which character is used for decimals and which is used for thousands
        if ($numberPart.LastIndexOf(',') -gt $numberPart.LastIndexOf('.')) {
            $decimalChar = ','
            $thousandsChar = '.'
        }
        else {
            $decimalChar = '.'
            $thousandsChar = ','
        }

        # Remove thousands separators as they are not needed for parsing
        $numberPart = $numberPart.Replace($thousandsChar, '')

        # Replace decimal separator with the one from InvariantCulture
        # This makes sure the decimal parses successfully using InvariantCulture
        $numberPart = $numberPart.Replace($decimalChar, 
            [System.Globalization.CultureInfo]::InvariantCulture.NumberFormat.CurrencyDecimalSeparator)
            
        return $numberPart
    }
}

function Get-NumberFormatCulture{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Number
    )

    process{

        # Try to parse with current culture first
        if ([decimal]::TryParse($Number, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::CurrentCulture, [ref]$null)) {
            return [System.Globalization.CultureInfo]::CurrentCulture
        }
        # If that fails, try with invariant culture
        elseif ([decimal]::TryParse($Number, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$null)) {
            return [System.Globalization.CultureInfo]::InvariantCulture
        }
        elseif ([decimal]::TryParse($Number, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::GetCultureInfo("es-ES"), [ref]$null)) {
            return [System.Globalization.CultureInfo]::GetCultureInfo("es-ES")
        }
        else {
            return $null
        }
    }
}