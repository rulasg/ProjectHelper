
function Sync-ProjectDatabase{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if(! $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Nothing to commit" | Write-MyHost
        return
    }

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Send update to project
    $db = Sync-Project -Database $db

    Save-ProjectDatabaseSafe -Database $db

    if (Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber) {
        "Still pending staged values" | Write-MyError
        return $false
    } else {
        "All ($stagedItemsCount) staged values synced" | Write-MyHost
        return $true
    }
}

function Sync-Project{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Database
    )

    $db = $Database

    $ItemsStagedId = $db.Staged.Keys | Copy-MyStringArray
    foreach($itemId in $ItemsStagedId){
        
        $itemStaged = $db.Staged.$itemId

        $FieldStagedId = $itemStaged.Keys | Copy-MyStringArray
        foreach($fieldId in $FieldStagedId){

            # Staged has the display value. 
            # Convert to the update value
            $value = ConvertTo-FieldValue -Field $itemStaged.$fieldId.Field -Value $itemStaged.$fieldId.Value
            $field = $itemStaged.$fieldId.Field

            $params = @{
                Database = $db
                ItemId = $itemId
                FieldId = $field.id
                FieldName = $field.name
                FieldType = $field.type
                FieldDataType = $field.dataType
                Value = $value
            }

            "Saving [$($params.Database.ProjectId)/$($params.ItemId)/$($params.FieldId) ($($params.FieldName)) = ""$($params.Value)"" ] ..." | Write-MyHost

            $call = Update-ProjectItem @params

            if ( ! (Test-UpdateProjectItemCall $call) ) {
                "FAILED !!" | Write-MyHost
                Write-Debug -section "Sync-Project" -Message "Update-ProjectItem call failed" -Object $call
                continue
            }

            # update database with change
            Set-ItemValue -Database $db -ItemId $call.itemId -FieldName $call.FieldName -Value $value

            # remove staged item field
            Remove-ItemStaged -Database $db -ItemId $itemId -FieldId $fieldId

            "Done" | Write-MyHost
        }
    }

    return $db
}

function Remove-ItemStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Database,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldId
    )

    $db = $Database

    if ($db.Staged.$ItemId.$FieldId) {
        $db.Staged.$ItemId.Remove($FieldId)
    }

    # If no more fields in item remove item
    if ($db.Staged.$ItemId.Count -eq 0) {
        $db.Staged.Remove($ItemId)
    }
}