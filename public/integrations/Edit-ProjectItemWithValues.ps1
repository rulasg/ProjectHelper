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
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$ItemId,
        [Parameter(Mandatory)][hashtable]$Values,
        [Parameter()][string]$FieldSlug,
        [Parameter()][object]$Fields
    )

    "[Edit-ProjectItemWithValues] [$itemid] >>>" | Write-MyDebug -Section "EditProjectItem"

    if($null -eq $Fields){
        "[Edit-ProjectItemWithValues] Retriving fields" | Write-MyDebug -Section "EditProjectItem"
        $Fields = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber
    } else {
        "[Edit-ProjectItemWithValues] Using provided fields" | Write-MyDebug -Section "EditProjectItem"
    }

    $count = 0

    # forech key in data do
    foreach ($key in $Values.Keys) {
        $fieldName = $FieldSlug + $key

        # Check if field exists
        $field = $fields | Where-Object { $_.name -eq $fieldName }
        if ($null -eq $field) {
            "[Edit-ProjectItemWithValues]Field $fieldName not found" | Write-MyDebug -Section "EditProjectItem"
            continue
        }
        
        "[Edit-ProjectItemWithValues]Editing field $fieldName with value $($Values[$key])" | Write-MyDebug -Section "EditProjectItem"
        Edit-ProjectItemValue -Owner $owner -ProjectNumber $projectNumber -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]
        $count++
    }

    "[Edit-ProjectItemWithValues] [$itemid] <<< Edited $count fields" | Write-MyDebug -Section "EditProjectItem"

} Export-ModuleMember -Function Edit-ProjectItemWithValues
