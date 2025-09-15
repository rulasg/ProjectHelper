function Sync-ProjectDatabaseAsync {
    [CmdletBinding()]
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
    $stagedItemsCount = $db.Staged.Keys.Count

    # Send update to project
    $db = Sync-ProjectAsync -Database $db -SyncBatchSize $SyncBatchSize

    # Saved changes to database
    Save-ProjectDatabase -Database $db

    if (Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber) {
        "Still pending staged values" | Write-MyError
        return $false
    }
    else {
        "All ($stagedItemsCount) staged values synced" | Write-MyHost
        return $true
    }

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

    $ItemsStagedId = $db.Staged.Keys | Copy-MyStringArray
    foreach ($itemId in $ItemsStagedId) {
        
        $itemStaged = $db.Staged.$itemId

        $FieldStagedId = $itemStaged.Keys | Copy-MyStringArray
        foreach ($fieldId in $FieldStagedId) {

            $value = $itemStaged.$fieldId.Value
            $field = $itemStaged.$fieldId.Field

            $params = @{
                Database      = $db
                ItemId        = $itemId
                FieldId       = $fieldId
                FieldName     = $field.name
                FieldType     = $field.type
                FieldDataType = $field.dataType
                Value         = $value
            }


            # "Calling  [$($params.Database.ProjectId)/$($params.ItemId)/$($params.FieldId) ($($params.FieldType)) = $($params.Value) ] ..." | Write-MyHost -NoNewLine

            $call = Update-ProjectItem @params -Async

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

        if (! (Test-UpdateProjectItemAsyncCall $call) ) {
            "Updating Project Item call Failed [$itemId/$fieldName/$value]" | Write-MyError
            continue
        }

        "Saving to database [$($call.projectId)/$($call.itemId)/$($call.fieldName) ($($call.FieldType)) = ""$($call.Value)"" ]" | Write-MyHost

        Set-ItemValue -Database $db -ItemId $call.itemId -FieldName $call.fieldName -Value $call.Value
        Remove-ItemStaged -Database $db -ItemId $call.itemId -FieldId $call.FieldId
    }

    Save-ProjectDatabase -Database $db

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
