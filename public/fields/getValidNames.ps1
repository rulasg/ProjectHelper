function Get-ValidNames{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)][string]$FieldName
    )

    ($owner, $projectNumber) = Resolve-ProjectParameters -DoNotThrow

    if ($null -eq $owner -or $null -eq $projectNumber) {
        return $null
    }

    $field = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber -Name $FieldName -Exact

    switch($field.dataType){
        "SINGLE_SELECT" { $ret = $field.MoreInfo }
        default { $ret = $null}
    }

    return $ret
}

function Get-ValidFieldsNames{
    [CmdletBinding()]
    param ()

    ($owner, $projectNumber) = Resolve-ProjectParameters -DoNotThrow

    if ($null -eq $owner -or $null -eq $projectNumber) {
        return $null
    }

    $field = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    return $field.name
}