
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
        "NUMBER"         { $ret = $Value -match '^\d+$'                  ;Break }
        "DATE"           { $ret = $Value | Test-DateFormat    ;Break }
        "SINGLE_SELECT"  { $ret = $($null -ne $Field.options.$Value)     ;Break}

        default          { $ret = $null }
    }

    if(-not $ret){
        "not valid value [$Value] for field [$($Field.name)] with type [$($Field.dataType)]" | Write-Verbose
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

function ConvertTo-FieldValue{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object]$Field,
        [Parameter(Position = 1)][string]$Value
    )

    $dataType = $Field.dataType

    switch ($dataType) {
        "TITLE"          { $ret = $value                                 ;Break }
        "TEXT"           { $ret = $value                                 ;Break }
        "NUMBER"         { $ret = $value                                 ;Break}
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