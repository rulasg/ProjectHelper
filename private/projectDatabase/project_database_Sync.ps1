
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
    $result = Sync-Project -Database $db

    if ($null -eq $result) {
        return $false
    }

    # Check that all values are updated before clearing staging
    $different = New-Object System.Collections.Hashtable
    foreach($idemId in $db.Staged.Keys){

        # skip if $itemid is not in items.
        # This happenon direct item edit. Edit without full project sync
        if(-not $db.items.$idemId){
            continue
        }

        foreach($fieldId in $db.Staged.$idemId.Keys){
            $fieldName = $db.fields.$fieldId.name

            $stagedV = $db.Staged.$idemId.$fieldId.Value
            $actualV = $db.items.$idemId.$fieldName

            if(!($stagedV -eq $actualV)){
                $diff = @{
                    Id = $idemId
                    Field = $fieldId
                    Staged = $stagedV
                    Actual = $actualV
                }
                $different.$itemId = $diff
            }

        }
    }

    if($different.Count -eq 0){
        $db.Staged = $null
        Save-ProjectDatabase -Database $db -Owner $owner -ProjectNumber $projectnumber
        return $true
    } else {
        "Error: Staged values are not equal to actual values" | Write-MyError
        $different | convertto-json | Write-MyError
        return $false
    }

}

function Sync-Project{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Database
    )

    $db = $Database

    $ItemsStagedId = $db.Staged.Keys
    foreach($itemId in $ItemsStagedId){
        
        $itemStaged = $db.Staged.$itemId
        $FieldStagedId = $db.Staged.$itemId.Keys
        foreach($fieldId in $FieldStagedId){

            $fieldStagedValue = $itemStaged.$fieldId.Value
            $field = $itemStaged.$fieldId.Field
            $fieldName = $field.name

            $params = @{
                Database = $db
                ItemId = $itemId
                FieldId = $fieldId
                Value = $fieldStagedValue
                FieldType = $field.type
                FieldDataType = $field.dataType
            }

            "Saving  [$($params.Database.ProjectId)/$($params.ItemId)/$($params.FieldId) ($($params.FieldType)) = $($params.Value) ] ..." | Write-MyHost -NoNewLine

            $call = Update-ProjectItem @params

            if ($null -eq $call.Result) {
                "FAILED !!" | Write-MyHost
                continue
            }

            # update database with change if exists
            $db.items | AddHashLink $itemId
            $db.items.$itemId.$fieldName = $fieldStagedValue

            # remove staged item field
            $db = Remove-ItemStaged -Database $db -ItemId $itemId -FieldId $fieldId

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

    if ($db.Staged.$ItemId.$FieldName) {
        $db.Staged.$ItemId.Remove($FieldName)
    }

    # If no more fields in item remove item
    if ($db.Staged.$ItemId.Count -eq 0) {
        $db.Staged.Remove($ItemId)
    }

    return $db
}