class ValidFields : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() { return @( "Status" ) }
}

function Get-ValidNames{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)][ValidateSet([ValidFields])][string]$FieldName
    )

    ($owner, $projectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber -DoNotThrow

    if ($null -eq $owner -or $null -eq $projectNumber) {
        return $null
    }

    $field = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber -Name $FieldName

    if($field.dataType -eq "SINGLE_SELECT"){
        $ret = $field.MoreInfo
    } else {
        throw "Get-ValidNames only supports fields with SINGLE_SELECT dataType. Field $FieldName has $($field.dataType) dataType."
    }

    return $ret
}