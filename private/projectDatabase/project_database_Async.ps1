Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValueAsync -Command 'Import-Module {projecthelper} ; Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'
Set-MyInvokeCommandAlias -Alias UpdateIssueAsync                          -Command 'Import-Module {projecthelper} ; Invoke-UpdateIssue -IssueId {id} -Title "{title}" -Body "{body}"'

function Sync-ProjectDatabaseAsync {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][int]$SyncBatchSize = 30
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

    if (! $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)) {
        "Nothing to commit" | Write-MyHost
        return
    }

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Send update to project
    $result = Sync-ProjectAsync -Database $db -SyncBatchSize $SyncBatchSize
    if ($null -eq $result) {
        return $false
    }

    # Clear the values that are the same
    $different = New-Object System.Collections.Hashtable
    $equal = New-Object System.Collections.Hashtable

    # Make a copy of the staged keys before processing
    $stagedItemKeys = @($db.Staged.Keys)

    foreach ($itemId in $stagedItemKeys) {

        # Make a copy of the staged fields keys before processing
        $stagedFieldsKeys = @($db.Staged.$itemId.Keys)

        # Process each staged field for the item
        foreach ($fieldId in $stagedFieldsKeys) {
            $fieldName = $db.fields.$fieldId.name

            # Skip if actual and staged values are the same
            $stagedV = $db.Staged.$itemId.$fieldId.Value
            $actualV = $db.items.$itemId.$fieldName

            if (!($stagedV -eq $actualV)) {
                # Create refe to failing
                $different."$($itemId)_$($Fieldid)" = @{
                    Id     = $itemId
                    Field  = $fieldId
                    Staged = $stagedV
                    Actual = $actualV
                }
            }
            else {
                # Create refe success
                $equal."$($itemId)_$($Fieldid)" = @{
                    Id    = $itemId
                    Field = $fieldId
                }
                # Remove staged field
                $db.Staged.$itemId.Remove($fieldId)
            }
        }

        # Remove staged item if all fields are removed
        if ($db.Staged.$itemId.Keys.Count -eq 0) {
            $db.Staged.Remove($itemId)
        }

    }

    $SyncedCount = $equal.Keys.Count
    $NotSyncedCount = $different.Keys.Count

    #null Staged if empty
    if ($db.Staged.Keys.Count -eq 0) {
        $db.Staged = $null
    }

    Save-ProjectDatabase -Database $db -Owner $owner -ProjectNumber $projectnumber

    if ($different.Count -ne 0) {
        "Not all Staged values are not equal to actual values" | Write-MyError
        $different | convertto-json | Write-MyError
        return $false
    }

    "Synced $SyncedCount values (Failed: $NotSyncedCount)" | Write-MyHost

    return $true

}

function Sync-ProjectAsync {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)][object]$Database,
        [Parameter()][int]$SyncBatchSize = 30
    )

    $db = $Database
    $calls = @()
    $callsBatch = @()

    foreach ($itemId in $db.Staged.Keys) {
        foreach ($fieldId in $db.Staged.$itemId.Keys) {

            # Get actual value on the database
            $fieldName = $db.fields.$fieldId

            # Get actual value on the database
            $actualValue = $db.items.$itemId.$fieldName

            # Skip if database has already the same value
            if ($actualValue -eq $db.Staged.$itemId.$fieldId.Value) {
                "Skipping [$itemId/$fieldName] as actual value is the same as staged value [$actualValue]" | Write-MyHost
                continue
            }

            $projectId = $db.ProjectId
            $dataType = $db.Staged.$itemId.$fieldId.Field.dataType
            $fieldName = $db.fields.$fieldId.name
            $value = $db.Staged.$itemId.$fieldId.Value
            $type = ConvertTo-UpdateType $db.Staged.$itemId.$fieldId.Field.dataType
            $fieldType = $db.Staged.$itemId.$fieldId.Field.type

            
            switch ($fieldType) {
                { $_ -in "title", "body" } {
                    "Calling to save Content [$itemId/$fieldId ($type) = $value ]" | Write-MyHost
                    $params = @{
                        projecthelper = $MODULE_PATH
                        id            = $itemId
                        title         = if ($fieldId -eq "title") { $value } else { "" }
                        body          = if ($fieldId -eq "body") { $value } else { "" }
                    }
                    # Invoke-UpdateIssue -IssueId {id} -Title "{title}" -Body "{body}"
                    $job = Start-MyJob -Command UpdateIssueAsync -Parameters $params
                    Break
                }

                default {
                    "Calling to save CustomField $dataType [$projectId/$itemId/$fieldId ($type) = $value ]" | Write-MyHost
                    $params = @{
                        projecthelper = $MODULE_PATH
                        projectid     = $projectId
                        itemid        = $itemId
                        fieldid       = $fieldId
                        value         = $value
                        type          = $type
                    }
                    # Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}
                    $job = Start-MyJob -Command GitHub_UpdateProjectV2ItemFieldValueAsync -Parameters $params
                }
            }

            $call = [PSCustomObject]@{
                job       = $job
                projectId = $projectId
                itemId    = $itemId
                value     = $value
                fieldId   = $fieldId
                type      = $type
                fieldName = $fieldName
                dataType  = $dataType
            }

            $calls += $call
            $callsBatch += $call

            # Call batch size if we reached the maximum batch size
            if ($callsBatch.count -eq $SyncBatchSize) {
                Waiting -Calls $callsBatch
                $callsBatch = @() # Reset the batch
            }

        }
    }

    #Remaining calls
    Waiting -Calls $callsBatch

    # Process all the calls
    foreach ($call in $calls) {

        $result = Receive-Job -Job $call.job

        $projectId = $call.projectId
        $itemId = $call.itemId
        $fieldId = $call.fieldId
        $fieldName = $call.fieldName
        $value = $call.value

        # TODO: We need to extend this to support PR too
        switch ($fieldId) {
            { $_ -in "title", "body" } { $checkValue = $result.data.updateIssue }
            default { $checkValue = $result.data.updateProjectV2ItemFieldValue.projectV2Item }
        }

        if ($null -eq $checkValue) {
            # TODO: Maybe worth checking response values to confirm change was made correctly even without error
            "Updating Project Item call Failed [$itemId/$fieldName/$value]" | Write-MyError
            continue
        }

        "Saving to database [$projectId/$itemId/$fieldName ($type) = $value ]" | Write-MyHost
        $db.items.$itemId.$fieldName = $value
        $db = Remove-ItemStaged -Database $db -ItemId $item_id -FieldName $fieldName
    }

    return $db
}

function Waiting($Calls) {
    $waitingJobs = $Calls.job

    $all = $Calls.Count
    "Waiting for [$all] jobs to complete " | Write-MyHost -noNewline

    while ($waitingJobs.Count -ne 0) {

        $waitings = $waitingJobs | Wait-Job -Any

        "." | Write-MyHost -NoNewline

        # Remove completed jobs from the waiting list
        $waitingJobs = $waitingJobs | Where-Object { $_.Id -ne $waitings.Id }

    }

    $completed = $Calls | Where-Object { $_.job.State -eq 'Completed' } | Measure-Object | Select-Object -ExpandProperty Count
    $failed = $Calls | Where-Object { $_.job.State -eq 'Failed' } | Measure-Object | Select-Object -ExpandProperty Count
    $all = $Calls.Count

    "" | Write-MyHost
    "Completed [$completed] Failed [$failed]" | Write-MyHost
}

# function Sync-Project {
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][object]$Database
#     )

#     $db = $Database

#     foreach ($idemId in $db.Staged.Keys) {
#         foreach ($fieldId in $db.Staged.$idemId.Keys) {

#             # Get actual value on the database
#             $fieldName = $db.fields.$fieldId.name

#             # Skip if database has already the same value as staged
#             if ($db.items.$itemId.$fieldName -eq $db.Staged.$itemId.$fieldId.Value) {
#                 "Skipping [$itemId/$fieldName] as actual value is the same as staged value [$actualValue]" | Write-MyHost
#                 continue
#             }

#             $project_id = $db.ProjectId
#             $item_id = $idemId
#             $field_id = $fieldId
#             $value = $db.Staged.$idemId.$fieldId.Value
#             $type = ConvertTo-UpdateType $db.Staged.$idemId.$fieldId.Field.dataType

#             $params = @{
#                 projectid = $project_id
#                 itemid    = $item_id
#                 fieldid   = $field_id
#                 value     = $value
#                 type      = $type
#             }

#             "Saving  [$project_id/$item_id/$field_id ($type) = $value ]" | Write-MyHost

#             $result = Invoke-MyCommand -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters $params

#             if ($null -eq $result) {
#                 "Updating Project Item Field [$item_id/$field_id/$value]" | Write-MyError
#                 return $null
#             }

#             # update database with change
#             $db.items.$item_id.$fieldName = $value

#         }
#     }

#     return $db
# }