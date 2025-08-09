<#
.SYNOPSIS
    Update the fields of an item with the Values of a HashTable
.DESCRIPTION
    Update the fields of an item with the Values of a HashTable
    The function will update the fields of the item with the values of the hashtable
    The hashtable keys must be the field names and the values must be the field values
#>
function Edit-ProjectItemWithValues {
    param (
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$ItemId,
        [Parameter(Mandatory)][hashtable]$Values,
        [Parameter()][string]$FieldSlug,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

    $fields = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    # forech key in data do
    foreach ($key in $Values.Keys) {
        $fieldName = $FieldSlug + $key

        # Check if field exists
        $field = $fields | Where-Object { $_.name -eq $fieldName }
        if ($null -eq $field) {
            "Field $fieldName not found" | Write-MyVerbose
            continue
        }

        # Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]
        Edit-Item -Database $db -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]
    }

    Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Database $db

} Export-ModuleMember -Function Edit-ProjectItemWithValues

