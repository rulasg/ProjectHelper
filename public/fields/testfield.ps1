function Test-ProjectField{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string]$FieldName
    )

    ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $fields = Get-ProjectFields -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = $fields.name -contains $FieldName

    return $ret
} Export-ModuleMember -Function Test-ProjectField