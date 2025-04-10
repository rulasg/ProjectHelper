Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValueAsync -Command 'Import-Module {projecthelper} ; Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'

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

    # Clear the values that are the same
    $different = New-Object System.Collections.Hashtable
    $equal = New-Object System.Collections.Hashtable
    foreach($itemId in $db.Staged.Keys){
        foreach($fieldId in $db.Staged.$itemId.Keys){
            $fieldName = $db.fields.$fieldId.name

            $stagedV = $db.Staged.$itemId.$fieldId.Value
            $actualV = $db.items.$itemId.$fieldName

            if(!($stagedV -eq $actualV)){
                # Create refe to failing
                $different."$($itemId)_$($Fieldid)" = @{
                    Id = $itemId
                    Field = $fieldId
                    Staged = $stagedV
                    Actual = $actualV
                }
            } else {
                # Create refe success
                $equal."$($itemId)_$($Fieldid)" = @{
                    Id = $itemId
                    Field = $fieldId
                }
            }
        }
    }

    $SyncedCount = $equal.Keys.Count
    $NotSyncedCount = $different.Keys.Count

    # removed equal staged values
    foreach($key in $equal.Keys){
        $itemId = $equal.$key.Id
        $fieldId = $equal.$key.Field

        # Remove staged field
        $db.Staged.$itemId.Remove($fieldId)

        # remove staged item if all are removed
        if($db.Staged.$itemId.Keys.Count -eq 0){
            $db.Staged.Remove($itemId)
        }
    }

    #null Staged if empty
    if($db.Staged.Keys.Count -eq 0){
        $db.Staged = $null
    }
    
    Save-Database -Key $dbkey -Database $db

    if($different.Count -ne 0){
        "Not all Staged values are not equal to actual values" | Write-MyError
        $different | convertto-json | Write-MyError
        return $false
    }

    "Synced $SyncedCount values (Failed: $NotSyncedCount)" | Write-MyHost

    return $true

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
                projecthelper = $MODULE_PATH
                projectid = $projectId
                itemid = $itemId
                fieldid = $fieldId
                value = $value
                type = $type
            }

            "Calling to save  [$projectId/$itemId/$fieldId ($type) = $value ]" | Write-MyHost

            $job = Start-MyJob -Command GitHub_UpdateProjectV2ItemFieldValueAsync -Parameters $params

            $call = [PSCustomObject]@{
                job = $job
                projectId = $projectId
                itemId = $itemId
                value = $value
                fieldId = $fieldId
                type = $type
                fieldName = $db.fields.$fieldId.name
            }

            $calls += $call

        }
    }

    # "Waiting for all calls to finish ..." | Write-MyHost
    # $results = $calls.job | Wait-Job
    
    $isDone = $false
    $all = $calls.job.Count
    $waitingJobs = $calls.job

    "Waiting for all calls to finish [$($waitingJobs.Count)] " | Write-MyHost -noNewline

    while(!$isdone){

        $waitings = $waitingJobs | Wait-Job -Any

        "." | Write-MyHost -NoNewline

        $completed = ($calls.job | Where-Object{$_.State -eq "Completed"}).Count
        $failed = ($calls.job | Where-Object{$_.State -eq "Failed"}).Count

        # $running = ($calls.job | Where-Object{$_.State -eq "Running"}).Count
        # "Running [$running] Completed [$completed] Failed [$failed] TOTAL [$all]" | Write-MyHost

        # Remove completed jobs from the waiting list
        $waitingJobs = $waitingJobs | Where-Object { $_.Id -ne $waitings.Id }
        
        $isDone = ($completed + $failed) -eq $all
    }
    "" | Write-MyHost
    "Completed [$completed] Failed [$failed] TOTAL [$all]" | Write-MyHost


    # Process all the calls
    foreach($call in $calls){

        $result = Receive-Job -Job $call.job

        $projectId = $call.projectId
        $itemId = $call.itemId
        $fieldId = $call.fieldId
        $fieldName = $call.fieldName
        $value = $call.value

        if ($null -eq $result.data.updateProjectV2ItemFieldValue.projectV2Item) {
            # TODO: Maybe worth checking response values to confirm change was made correctly even without error
            "Updating Project Item call Failed [$itemId/$fieldName/$value]" | Write-MyError
            continue
        }

        "Saving to database [$projectId/$itemId/$fieldName ($type) = $value ]" | Write-MyHost

        if ($PSCmdlet.ShouldProcess($itemId, "Set-ProjectV2Item")) {
            # update database with change
            $db.items.$itemId.$fieldName = $value
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