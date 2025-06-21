
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValue -Command 'Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'

function Sync-ProjectDatabase{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if(! $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Nothing to commit" | Write-MyHost
        return
    }

    $dbkey = Get-DatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber

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
        Save-Database -Key $dbkey -Database $db
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

    foreach($idemId in $db.Staged.Keys){
        foreach($fieldId in $db.Staged.$idemId.Keys){

            $fieldName = $db.fields.$fieldId.name

            # if($db.items.$idemId.$fieldName -eq $db.Staged.$idemId.$fieldId.Value){
            #     "Skipping [$idemId/$fieldId] as value is the same" | Write-MyHost
            #     continue
            # }

            $project_id = $db.ProjectId
            $item_id = $idemId
            $field_id = $fieldId
            $value = $db.Staged.$idemId.$fieldId.Value
            $type = ConvertTo-UpdateType $db.Staged.$idemId.$fieldId.Field.dataType

            $params = @{
                projectid = $project_id
                itemid = $item_id
                fieldid = $field_id
                value = $value
                type = $type
            }

            "Saving  [$project_id/$item_id/$field_id ($type) = $value ] ..." | Write-MyHost -NoNewLine

            $result = Invoke-MyCommand -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters $params

            if ($null -eq $result) {
                "FAILED !!" | Write-MyHost
                continue
            }

            # update database with change if exists
            if($db.items.$item_id ){
                $db.items.$item_id.$fieldName = $value
            }

            "Done" | Write-MyHost
        }
    }

    return $db
}



function ConvertTo-UpdateType{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$DataType
    )

            # [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]

    switch ($DataType) {
        "TEXT"           { $ret = "text"                 ;Break }
        "TITLE"          { $ret = "text"                 ;Break }
        "NUMBER"         { $ret = "number"               ; Break}
        "DATE"           { $ret = "date"                 ; Break}
        "iterationId"    { $ret = "iterationId"          ; Break}
        "SINGLE_SELECT"  { $ret = "singleSelectOptionId" ;Break }

        default          { $ret = $null }
    }

    return $ret

    # "SINGLE_SELECT"
    # "TEXT" , "TITLE"
    # "NUMBER"
    # "DATE"

    # "ASSIGNEES"
    # "LABELS"
    # "LINKED_PULL_REQUESTS"
    # "TRACKS"
    # "REVIEWERS"
    # "REPOSITORY"
    # "MILESTONE"
    # "TRACKED_BY"
}
