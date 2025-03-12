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
        [Parameter()][string]$FieldSlug
    )

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

        Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]

    }

} Export-ModuleMember -Function Edit-ProjectItemWithValues

function Update-ItemWithIntegration_POC{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project
    $items = Get-ProjectItemList -owner $Owner -ProjectNumber $ProjectNumber

    # List the items that have the integration ID
    $itemswithIntegration = $items
    
} Export-ModuleMember -Function Update-ItemWithIntegration_POC