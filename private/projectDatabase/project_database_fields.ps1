
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

function Test-FieldChange{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 1)][object]$Field,
        [Parameter(Position = 2)][string]$Value
    )

    # TODO !! : Pending check if value is correct based on field type
    # So far the Fields do not contain the field type.

    return $true
}

function Get-FieldValue{
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