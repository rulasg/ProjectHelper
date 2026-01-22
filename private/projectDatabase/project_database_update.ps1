# We need to invoke a call back to allow the mock of this call on testing
Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFields          -Command 'Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber} -afterFields "{afterFields}" -afterItems "{afterItems}" -query "{query}"'
Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFieldsSkipItems -Command 'Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber} -afterFields "{afterFields}" -afterItems "{afterItems}" -firstItems 0 -query "{query}"'

function Update-ProjectDatabase {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][string]$Query,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber ; afterFields = "" ; afterItems = "" ; query = "$query" }

    # This means that the ProjectNumber has a empty string value
    if($ProjectNumber -eq 0){
        throw "ProjectNumber invalid. Please specify a valid ProjectNumber"
    }

    # check if there are unsaved changes
    $saved = Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber
    if($saved -and -Not $Force){
        throw "There are unsaved changes. Restore changes with Reset-ProjectItemStaged or sync projects with Sync-ProjectItemStaged first and try again"
    }

    $items = New-Object System.Collections.Hashtable
    $fields = New-Object System.Collections.Hashtable

    do {

        if($SkipItems){
            $result  = Invoke-MyCommand -Command GitHubOrgProjectWithFieldsSkipItems -Parameters $params
        } else {
            $result  = Invoke-MyCommand -Command GitHubOrgProjectWithFields -Parameters $params
        }

        # check if the result is empty
        if($null -eq $result){
            "Updating ProjectDatabase for project [$Owner/$ProjectNumber]" | Write-MyError
            return $false
        }

        $projectV2 = $result.data.organization.ProjectV2

        if($SkipItems){
            $hasNextPageItems = $false
        } else {
            # Check if we have already processed all the items
            if($result.data.organization.projectv2.items.totalCount -ne $items.Count){
                $items = Convert-ItemsFromResponse $projectV2 | Add2HashTable $items
            }
            $params.afterItems = $result.data.organization.projectv2.items.pageInfo.endCursor
            $hasNextPageItems = $result.data.organization.projectv2.items.pageInfo.hasNextPage
        }

        # Check if we have already processed all the fields
        if($result.data.organization.projectv2.fields.totalCount -ne $fields.Count){
            $fields = Convert-FieldsFromReponse $projectV2 | Add2HashTable $fields
        }
        $params.afterFields = $result.data.organization.projectv2.fields.pageInfo.endCursor
        $hasNextPageFields = $result.data.organization.projectv2.fields.pageInfo.hasNextPage

        # Write the progress
        "GithubOrgProjectWithFields - Items [$($items.count)/$($result.data.organization.ProjectV2.Items.totalCount)] Fields [$($fields.count)/$($result.data.organization.ProjectV2.fields.totalCount)]" | Write-MyHost

    } while (
        $hasNextPageItems -or $hasNextPageFields
    )

    # Check that we have retreived all the items
    if(!$SkipItems -and $result.data.organization.projectv2.items.totalCount -ne $items.Count){
        "Items count mismatch. Expected [$($result.data.organization.projectv2.items.totalCount)] Found [$($items.count)]" | Write-MyWarning
        return $false
    }
    # Check that we have retreived all the fields
    if($result.data.organization.projectv2.fields.totalCount -ne $fields.Count){
        "Fields count mismatch. Expected [$($result.data.organization.projectv2.fields.totalCount)] Found [$($fields.count)]" | Write-MyWarning
        return $false
    }

    # Add content fields
    $fields = $fields | Set-ContentFields

    # If query is set we are updating just a few items from the database.
    # update just this items
    if( -Not [string]::IsNullOrEmpty($Query)){
        $actualprj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

        # Check if project has no items or the project is not cached yet
        $actualItems = $actualprj.items ?? $(New-HashTable)

        foreach($itemKey in $items.Keys){
            $actualItems.$itemKey = $items.$itemKey
        }
        $items = $actualItems
    }

    # Save ProjectV2 object to ProjectDatabase
    Save-ProjectV2toDatabase $projectV2 -Items $items -Fields $fields

    return $true
} Export-ModuleMember -Function Update-ProjectDatabase

<#
.SYNOPSIS
    This function adds the content of a hashtable to another hashtable.
.DESCRIPTION
    # HTA += HTB
    # $HTA Add-ToHashTable $HTB
    # We can not use += operator as it will create a key case sensitive hashtable.
    # This way it does not fail when adding the same key with different case
    # $items += $ut
#>
function Add2HashTable{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][hashtable]$HTA,
        [Parameter(ValueFromPipeline,Position = 1)][hashtable]$HTB
    )

    process {
        foreach ($key in $HTB.Keys) {
            $HTA[$key] = $HTB[$key]
        }
    }

    end{
        return $HTA
    }
}

function Convert-ItemsFromResponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2
    )

    $items = New-HashTable

    $nodes = $ProjectV2.items.nodes

    foreach ($nodeItem in $nodes) {

        $itemId = $nodeItem.id

        $item = Convert-NodeItemToHash -NodeItem $nodeItem

        try {
            $items.$itemId = $item
        } catch {
            "Failed to add item $itemId to items collection" | Write-Error
        }
    }
    return $Items
}

function Convert-FieldsFromReponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2
    )
    $fields = New-Object System.Collections.Hashtable

    # Custom properties comming from project
    foreach ($node in $ProjectV2.fields.nodes) {
        $fieldId = $node.id

        $field = @{
            id = $node.id
            dataType = $node.dataType
            type = $node.__typename
            name = $node.name
        }

        if ($field.dataType -eq "SINGLE_SELECT") {
            $field.options = New-Object System.Collections.Hashtable
            foreach ($option in $node.options) {
                $field.options.$($option.name) = $option.id
            }
        }
        $fields.$fieldId = $field
    }

    return $fields
}

function Set-ContentFields {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$Fields
    )

    # TITLE
    # Remove Title field comming from CustomFields
    $fieldTitleId = $fields.Keys | Where-Object {$fields.$_.dataType -eq "TITLE"}
    $fields.Remove($fieldTitleId)

    # Check that Title field does not exist
    $fieldTitleId = $fields.Keys | Where-Object {$fields.$_.name -eq "Title"}
    if($fieldTitleId){
        throw "Set-ContentFields: [ Title ] field already exists. Please remove or rename this field from the project"
    }

    # Add new title field
    $fields.title = @{
        id       = "title"
        dataType = "TITLE"
        type     = "ContentField"
        name     = "Title"
    }

    # BODY
    # Check that BODY field does not exist
    $fieldBodyId = $fields.Keys | Where-Object {$fields.$_.name -eq "Body"}
    if($fieldBodyId){
        throw "Set-ContentFields: [ Body ] field already exists. Please remove or rename this field from the project"
    }
    # Add BODY
    $fields.body = @{
        id       = "body"
        dataType = "BODY"
        type     = "ContentField"
        name     = "Body"
    }

    # AddComments
    # Check that AddComment field does not exist
    $fieldCommentId = $fields.Keys | Where-Object {$fields.$_.name -eq "AddComment"}
    if($fieldCommentId){
        throw "Set-ContentFields: [ AddComment ] field already exists. Please remove or rename this field from the project"
    }
    $fields.comments = @{
        id       = "addcomment"
        dataType = "ADDCOMMENT"
        type     = "ContentField"
        name     = "AddComment"
    }

    return $Fields
}

function GetDateTime{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$DateTimeString
    )
    if([string]::IsNullOrEmpty($DateTimeString)){
        return $null
    }
    try {
        # Parse date string as UTC format to ensure consistency across different locales
        $date = [datetime]::Parse($DateTimeString, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AdjustToUniversal)
    } catch {
        "Failed to parse date [$DateTimeString]" | Write-Error
        return $null
    }
    return $date
}

function GetUsers{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$FieldNode
    )

    # sanity check
    if($FieldNode.__typename -ne "ProjectV2ItemFieldUserValue"){
        throw "GetUsers: FieldNode is not a ProjectV2ItemFieldUserValue"
    }
    $ret = $FieldNode.users.nodes.login
    $ret = $ret -join ","

    return $ret
}

function GetLabels{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$FieldNode
    )

    # sanity check
    if($FieldNode.__typename -ne "ProjectV2ItemFieldLabelValue"){
        throw "GetLabels: FieldNode is not a ProjectV2ItemFieldLabelValue"
    }
    $ret = @()
    foreach($node in $FieldNode.labels.nodes){
        $ret += $node.name
    }

    $ret = $ret | ConvertTo-Json

    return $ret
}

function GetPullRequests{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$FieldNode
    )

    # sanity check
    if($FieldNode.__typename -ne "ProjectV2ItemFieldPullRequestValue"){
        throw "GetPullRequests: FieldNode is not a ProjectV2ItemFieldPullRequestValue"
    }
    $ret = @()
    foreach($node in $FieldNode.pullRequests.nodes){
        $ret += $node.url
    }

    $ret = $ret | ConvertTo-Json

    return $ret
}