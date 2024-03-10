
function Get-Field{
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$FieldName
    )

    $field = $Database.Fields.Values | Where-Object { $_.name -eq $FieldName }

    return $field
}

function Test-FieldChange{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 1)][object]$Field,
        [Parameter(Position = 2)][string]$Value
    )

    # TODO : Pending check if value is correct based on field type
    # So far the Fields do not contain the field type.

    return $true
}
