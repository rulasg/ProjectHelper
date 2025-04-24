
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

    switch ($dataType) {
        "TITLE"          { $ret = $true;Break }
        "TEXT"           { $ret = $true                                  ;Break }
        "NUMBER"         { $ret = $Value | Test-NumberFormat             ;Break }
        "DATE"           { $ret = $Value | Test-DateFormat               ;Break }
        "SINGLE_SELECT"  { $ret = $($null -ne $Field.options.$Value)     ;Break}

        default          { $ret = $null }
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
        "TITLE"          { $ret = $value                                 ;Break}
        "TEXT"           { $ret = $value                                 ;Break}
        "NUMBER"         { $ret = $value | ConvertTo-Number              ;Break}
        "DATE"           { $ret = $value                                 ;Break}
        "SINGLE_SELECT"  { $ret = $Field.options.$Value                  ;Break}

        default          { $ret = $null }
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
        "TITLE"          { $ret = $value                                                            ;Break }
        "TEXT"           { $ret = $value                                                            ;Break }
        "NUMBER"         { $ret = $value                                                            ;Break}
        "DATE"           { $ret = $value                                                            ;Break}
        "SINGLE_SELECT"  { $ret = $Field.options.Keys | Where-Object {$Field.options.$_ -eq $value} ;Break}

        default          { $ret = $null }
    }

    return $ret
}

# funciton Test-DateFormat what will test strings with the date format YYYY-MM-DD
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

function Test-NumberFormat{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Number
    )

    process{

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

# function ConvertTo-Number2 {
#     [CmdletBinding()]
#     [OutputType([string])]
#     param(
#         [Parameter(ValueFromPipeline)][string]$Value
#     )
#     process {
#         $culture = Get-NumberFormatCulture $Value
#         if ($null -ne $culture) {

#             try {
#                 return  [decimal]::Parse($Value, [System.Globalization.NumberStyles]::Any, $culture)

#             }
#             catch {
#                 throw "Error parsing number: $_"
#             }
#         }
#         else {
#             throw "Could not determine number format for: $Value"
#         }
#     }
# }

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