Set-MyInvokeCommandAlias -Alias UpdateIssue                               -Command 'Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdatePullRequest                         -Command 'Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdateDraftIssue                          -Command 'Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValue      -Command 'Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'
Set-MyInvokeCommandAlias -Alias UpdateIssueAsync                          -Command 'Import-Module {projecthelper} ; Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdatePullRequestAsync                    -Command 'Import-Module {projecthelper} ; Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias UpdateDraftIssueAsync                     -Command 'Import-Module {projecthelper} ; Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValueAsync -Command 'Import-Module {projecthelper} ; Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'

Set-MyInvokeCommandAlias -Alias GitHub_ClearProjectV2ItemFieldValueAsync  -Command 'Import-Module {projecthelper} ; Invoke-GitHubClearItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid}'
Set-MyInvokeCommandAlias -Alias GitHub_ClearProjectV2ItemFieldValue       -Command 'Invoke-GitHubClearItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid}'

Set-MyInvokeCommandAlias -Alias AddComment      -Command 'Invoke-AddComment -SubjectId {subjectid} -Comment "{comment}"'
Set-MyInvokeCommandAlias -Alias AddCommentAsync -Command 'Import-Module {projecthelper} ; Invoke-AddComment -SubjectId {subjectid} -Comment "{comment}"'

function Update-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Database,
        [Parameter(Mandatory, Position = 1)][string]$ItemId,
        [Parameter(Mandatory, Position = 2)][string]$FieldId,
        [Parameter(Mandatory, Position = 2)][string]$FieldName,
        [Parameter(Mandatory, Position = 3)][string]$FieldType,
        [Parameter(Mandatory, Position = 4)][string]$FieldDataType,
        [Parameter(Position = 5)][string]$Value,
        [Parameter()][switch]$Async
    )

    $result = $null
    $job = $null

    if ($FieldType -eq "ContentField") {

        $type, $contentId = GetItemInfo -ItemId $ItemId -Database $Database

        switch ($type) {
            "DraftIssue" {
                $result, $job, $resultDataType = Update-DraftIssue -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
                break
            }
            "Issue" {
                $result, $job, $resultDataType = Update-Issue -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
                break
            }
            "PullRequest" {
                $result, $job, $resultDataType = Update-PullRequest -Id $contentId -FieldId $FieldId -Value $Value -Async:$Async
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

        $result, $job , $resultDataType = Update-ItemField @params -Async:$Async

    }

    if ($null -eq $result -and $null -eq $job) {
        throw "Assertion failed: both result and job are null (ProjectId=$($database.ProjectId), ItemId=$ItemId, FieldId=$FieldId)."
    }

    $call = [PSCustomObject]@{
        Result         = $result
        Job            = $job
        ProjectId      = $database.ProjectId
        ItemId         = $ItemId
        Value          = $Value
        FieldId        = $FieldId
        ResultDataType = $resultDataType
        FieldName      = $FieldName
        DataType       = $FieldDataType
    }

    return $call
}
function GetItemInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Database,
        [Parameter(Mandatory, Position = 1)][string]$ItemId
    )
    # Get Item to know what we are updating
    $item = Get-Item -Database $Database -ItemId $ItemId

    # TODO: Situation where we are updating an item that is not cached and therefore type is not known
    if (-not $item.type) {
        # Single fetch item from api
        # memory Database is updated wit the item too
        $item = Resolve-ProjectItem -Database $Database -ItemId $ItemId
    }

    if ( $null -eq $item) {
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
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$FieldId,
        [Parameter()][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update Issue Async[$Async] [$Id/$FieldId = ""$Value"" ]" | Write-MyHost

    if($FieldId -eq "addcomment"){
        # ADD COMMENT

        if([string]::IsNullOrWhiteSpace($Value)){
            "Comment value is empty" | Write-MyWarning
            return $null, $null, "addComment"
        } 

         $params =  @{
                subjectid = $Id
                comment   = $Value
         }
         
        if ($Async) {
            $params.projecthelper = $MODULE_PATH
            $job = Start-MyJob -Command AddCommentAsync -Parameters $params

        }
        else {
            $result = Invoke-MyCommand -Command AddComment -Parameters $params
        }

        $returnType = "addComment"
    
    } else {
        # TITLE AND BODY
        
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
        
        $returnType = "updateIssue"
    }

    return $result, $job, $returnType
}

function Update-PullRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$FieldId,
        [Parameter()][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update PullRequest Async[$Async] [$Id/$FieldId = ""$Value"" ]" | Write-MyHost

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

    return $result, $job , "updatePullRequest"
}

function Update-DraftIssue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$FieldId,
        [Parameter()][string]$Value,
        [Parameter()][switch]$Async
    )

    "Calling to update DraftIssue Async[$Async] [$Id/$FieldId = ""$Value"" ]" | Write-MyHost

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


    return $result, $job , "updateProjectV2DraftIssue"
}

function Update-ItemField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [Parameter(Mandatory)][string]$ItemId,
        [Parameter(Mandatory)][string]$FieldId,
        [Parameter(Mandatory)][string]$DataType,
        [Parameter()][string]$Value,
        [Parameter()][switch]$Async
    )

    $type = ConvertTo-UpdateType $DataType

    "Calling to update ItemField Async[$Async][$ProjectId/$ItemId/$FieldId ($type) = ""$Value"" ]" | Write-MyHost

    $params = @{
        projecthelper = $MODULE_PATH
        projectid     = $ProjectId
        itemid        = $ItemId
        fieldid       = $FieldId
        value         = $Value
        type          = $type
    }

    if ($Async) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            $job = Start-MyJob -Command GitHub_ClearProjectV2ItemFieldValueAsync -Parameters $params
            $resultDataType = "clearProjectV2ItemFieldValue"
        }
        else {
            $job = Start-MyJob -Command GitHub_UpdateProjectV2ItemFieldValueAsync -Parameters $params
            $resultDataType = "updateProjectV2ItemFieldValue"
        }
    }
    else {
        
        if ([string]::IsNullOrWhiteSpace($value)) {
            $result = Invoke-MyCommand -Command GitHub_ClearProjectV2ItemFieldValue -Parameters $params
            $resultDataType = "clearProjectV2ItemFieldValue"
        }
        else {
            $result = Invoke-MyCommand -Command GitHub_UpdateProjectV2ItemFieldValue -Parameters $params
            $resultDataType = "updateProjectV2ItemFieldValue"
        }
    }

    return $result, $job , $resultDataType
}

function Test-UpdateProjectItemAsyncCall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Call
    )

    $result = Receive-Job -Job $Call.job

    $ret = $null -ne $result.data.$($call.ResultDataType)

    if (! $ret) {
        "Update Project Item Async call Failed: $($result.errors.message -join ', ')" | Write-Verbose
    }

    return $ret
}

function Test-UpdateProjectItemCall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][object]$Call
    )

    $ret = $null -ne $call.Result.data.$($call.ResultDataType)

    if (! $ret) {
        "Update Project Item call Failed: $($call.Result.errors.message -join ', ')" | Write-Debug
    }

    return $ret
}