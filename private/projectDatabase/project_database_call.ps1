Set-MyInvokeCommandAlias -Alias UpdateIssue                               -Command 'Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdatePullRequest                         -Command 'Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdateDraftIssue                          -Command 'Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValue      -Command 'Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'
Set-MyInvokeCommandAlias -Alias UpdateIssueAsync                          -Command 'Import-Module {projecthelper} ; Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdatePullRequestAsync                    -Command 'Import-Module {projecthelper} ; Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdateDraftIssueAsync                     -Command 'Import-Module {projecthelper} ; Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValueAsync -Command 'Import-Module {projecthelper} ; Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'


function Update-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Database,
        [Parameter(Mandatory, Position = 1)][string]$ItemId,
        [Parameter(Mandatory, Position = 2)][string]$FieldId,
        [Parameter(Mandatory, Position = 3)][string]$FieldType,
        [Parameter(Mandatory, Position = 4)][string]$FieldDataType,
        [Parameter(Mandatory, Position = 5)][string]$Value,
        [Parameter()][switch]$Async
    )

    $result = $null
    $job = $null

    if ($FieldType -eq "ContentField") {
        
        $type, $contentId = GetItemInfo($ItemId)

        switch ($type) {
            "DraftIssue" {
                $result, $job = Update-DraftIssue -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
                break
            }
            "Issue" {
                $result, $job = Update-Issue -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
                break
            }
            "PullRequest" {
                $result, $job = Update-PullRequest -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
                break
            }

            default { 
                throw "Item type $($item.type) not supported for update"
            }
        }

    }
    else {

        $params = @{
            ProjectId = $database.ProjectId
            ItemId    = $ItemId
            FieldId   = $FieldId
            Value     = $Value
            DataType  = $FieldDataType
        }
        
        $result, $job = Update-ItemField @params -Async:$Async
    }

    if ($null -eq $result -and $null -eq $job) {
        throw "Assertion failed: both result and job are null (ProjectId=$ProjectId, ItemId=$ItemId, FieldId=$FieldId)."
    }

    $call = [PSCustomObject]@{
        Result    = $result
        Job       = $job
        ProjectId = $ProjectId
        ItemId    = $ItemId
        Value     = $Value
        FieldId   = $FieldId
        Type      = $updateDataType
        FieldName = $FieldId
        DataType  = $FieldDataType
    }

    return $call
}

function GetItemInfo($itemId) {
    # Get Item to know what we are updating
    $item = Get-Item -Database $Database -ItemId $ItemId

    # TODO: Situation where we are updating an item that is not cached and therefore type is not known
    if (-not $item.type) {
        $item = Get-ProjectItemDirect -ItemId $ItemId
    }

    if( $null -eq $item) {
        throw "Item $ItemId not found in database and could not be retrieved directly"
    }

    return $item.type, $item.contentId

}

function ConvertTo-UpdateType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$DataType
    )

    # [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]

    switch ($DataType) {
        "TEXT" { $ret = "text"                 ; Break }
        "TITLE" { $ret = "text"                 ; Break }
        "NUMBER" { $ret = "number"               ; Break }
        "DATE" { $ret = "date"                 ; Break }
        "iterationId" { $ret = "iterationId"          ; Break }
        "SINGLE_SELECT" { $ret = "singleSelectOptionId" ; Break }

        default { $ret = $null }
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

function Update-Issue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Id,
        [Parameter(Mandatory, Position = 1)][string]$FieldId,
        [Parameter(Position = 1)][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update Issue Async[$Async] [$Id/$FieldId = $Value ]" | Write-MyHost

    $params = @{
        id    = $Id
        title = if ($FieldId -eq "title") { $Value } else { "" }
        body  = if ($FieldId -eq "body") { $Value } else { "" }
    }

    if ($Async) {
        $params.projecthelper = $MODULE_PATH
        $job = Start-MyJob -Command UpdateIssueAsync -Parameters $params

    }
    else {
        $result = Invoke-MyCommand -Command UpdateIssue -Parameters $params
    }


    return $result, $job
}

function Update-PullRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Id,
        [Parameter(Mandatory, Position = 1)][string]$FieldId,
        [Parameter(Position = 1)][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update PullRequest Async[$Async] [$Id/$FieldId = $Value ]" | Write-MyHost

    $params = @{
        id    = $Id
        title = if ($FieldId -eq "title") { $Value } else { "" }
        body  = if ($FieldId -eq "body") { $Value } else { "" }
    }

    if ($Async) {
        $params.projecthelper = $MODULE_PATH
        $job = Start-MyJob -Command UpdatePullRequestAsync -Parameters $params
    }
    else {
        $result = Invoke-MyCommand -Command UpdatePullRequest -Parameters $params
    }


    return $result, $job
}

function Update-DraftIssue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Id,
        [Parameter(Mandatory, Position = 1)][string]$FieldId,
        [Parameter(Position = 1)][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update DraftIssue Async[$Async] [$Id/$FieldId = $Value ]" | Write-MyHost

    $params = @{
        id    = $Id
        title = if ($FieldId -eq "title") { $Value } else { "" }
        body  = if ($FieldId -eq "body") { $Value } else { "" }
    }

    if ($Async) {
        $params.projecthelper = $MODULE_PATH
        $job = Start-MyJob -Command UpdateDraftIssueAsync -Parameters $params
    }
    else {
        $result = Invoke-MyCommand -Command UpdateDraftIssue -Parameters $params
    }


    return $result, $job
}

function Update-ItemField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$ProjectId,
        [Parameter(Mandatory, Position = 1)][string]$ItemId,
        [Parameter(Mandatory, Position = 2)][string]$FieldId,
        [Parameter(Mandatory, Position = 3)][string]$Value,
        [Parameter(Mandatory, Position = 4)][string]$DataType,
        [Parameter()][switch]$Async
    )

    $type = ConvertTo-UpdateType $DataType

    "Calling to update ItemField Async[$Async][$ProjectId/$ItemId/$FieldId ($type) = $Value ]" | Write-MyHost

    if ($Async) {
        $ret = Start-MyJob -Command GitHub_UpdateProjectV2ItemFieldValueAsync -Parameters @{
            projecthelper = $MODULE_PATH
            projectid     = $ProjectId
            itemid        = $ItemId
            fieldid       = $FieldId
            value         = $Value
            type          = $Type
        }
    }
    else {
        $ret = Invoke-MyCommand -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters @{
            projectid = $ProjectId
            itemid    = $ItemId
            fieldid   = $FieldId
            value     = $Value
            type      = $Type
        }
    }

    return $ret
}