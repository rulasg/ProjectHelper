function Sync-ProjectDatabaseAsync{
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

    $dbkey = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Send update to project
    $result = Sync-ProjectAsync -Database $db
    if ($null -eq $result) {
        return $false
    }

    # Check that all values are updated before cleanring staging
    $different = New-Object System.Collections.Hashtable
    foreach($idemId in $db.Staged.Keys){
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

function Sync-ProjectAsync{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)][object]$Database
    )

    $db = $Database
    $calls = @()

    foreach($itemId in $db.Staged.Keys){
        foreach($fieldId in $db.Staged.$itemId.Keys){

            $projectId = $db.ProjectId
            $value = $db.Staged.$itemId.$fieldId.Value
            $type = ConvertTo-UpdateType $db.Staged.$itemId.$fieldId.Field.dataType

            $params = @{
                projectid = $projectId
                itemid = $itemId
                fieldid = $fieldId
                value = $value
                type = $type
            }

            "Calling to save  [$projectId/$itemId/$fieldId ($type) = $value ]" | Write-MyHost

            $job = Start-MyJob -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters $params

            $call = [PSCustomObject]@{
                job = $job
                itemId = $itemId
                value = $value
                fieldName = $db.fields.$fieldId.name
            }

            $calls += $call

        }
    }

    $results = $calls.job | Wait-Job

    foreach($call in $calls){
        "Saving to database [$project_id/$itemid/$fieldId ($type) = $value ]" | Write-MyHost

        $result = Receive-Job -Job $call.job
        
        if ($null -eq $result.data.updateProjectV2ItemFieldValue.projectV2Item) {
            "Updating Project Item Field [$itemid/$fieldId/$value]" | Write-MyError
        }

        # TODO: Maybe worth cheking response values to confirm change was made correctly even without error
        # $item = Convert-ItemFromResponse $result.data.updateProjectV2ItemFieldValue.projectV2Item


        if ($PSCmdlet.ShouldProcess($item.url, "Set-ProjectV2Item")) {
            # update database with change
            $fieldname = $call.fieldName
            $db.items.$itemid.$fieldName = $call.value
        }
    }

    return $db
}

function Sync-Project{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Database
    )

    $db = $Database

    foreach($idemId in $db.Staged.Keys){
        foreach($fieldId in $db.Staged.$idemId.Keys){

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

            "Saving  [$project_id/$item_id/$field_id ($type) = $value ]" | Write-MyHost

            $result = Invoke-MyCommand -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters $params

            if ($null -eq $result) {
                "Updating Project Item Field [$item_id/$field_id/$value]" | Write-MyError
                return $null
            }

            if ($PSCmdlet.ShouldProcess($item.url, "Set-ProjectV2Item")) {
                # update database with change
                $fieldName = $db.fields.$fieldId.name
                $db.items.$item_id.$fieldName = $value

                # $item = Convert-ItemFromResponse $projectV2Item
                # Set-ProjectV2Item2Database $db $projectV2Item -Item $item
                # $projectV2Item = $result.data.updateProjectV2ItemFieldValue.projectV2Item
            }
        }
    }

    return $db
}