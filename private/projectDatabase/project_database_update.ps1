# We need to invoke a call back to allow the mock of this call on testing
Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFields          -Command 'Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber} -afterFields "{afterFields}" -afterItems "{afterItems}"'
Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFieldsSkipItems -Command 'Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber} -afterFields "{afterFields}" -afterItems "{afterItems}" -firstItems 0'

function Update-ProjectDatabase {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber ; afterFields = "" ; afterItems = "" }

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

    # Set-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Items $items -Fields $fields
    Set-ProjectDatabaseV2 $projectV2 -Items $items -Fields $fields

    return $true
}

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

    foreach($nodeItem in $nodes){

        "Processing Item $($nodeItem.id) - $($nodeItem.content.title)" | Write-Verbose

        $itemId = $nodeItem.id

        # TODO !! - Refactor to call Convert-ItemFromResponse for each node utem

        $item = New-Object System.Collections.Hashtable
        $item.id = $itemId

        # Content
        $item.type = $nodeItem.content.__typename
        $item.body = $nodeItem.content.body
        $item.contentId = $nodeItem.content.id
        # Title is stored in two places. in the content and as a field.
        # We will use the field value
        # $item.title = $nodeItem.content.title
        $item.number = $nodeItem.content.number
        $item.url = $nodeItem.content.url
        $item.state = $nodeItem.content.state

        $item.createdAt = GetDateTime -DateTimeString $nodeItem.content.createdAt
        $item.updatedAt = GetDateTime -DateTimeString $nodeItem.content.updatedAt

        #Fields
        foreach($nodefield in $nodeItem.fieldValues.nodes){

            "      Procesing $($nodefield.field.name)" | Write-Verbose

            switch($nodefield.__typename){
                "ProjectV2ItemFieldTextValue" {
                    $value = $nodefield.text
                }
                "ProjectV2ItemFieldSingleSelectValue" {
                    $value = $nodefield.name
                }
                "ProjectV2ItemFieldNumberValue" {
                    $value = $nodefield.number
                }
                "ProjectV2ItemFieldDateValue" {
                    $value = $nodefield.date
                }
                "ProjectV2ItemFieldUserValue" {
                    $value = GetUsers -FieldNode $nodefield
                }
                "ProjectV2ItemFieldRepositoryValue" {
                    $value = $nodefield.repository.url
                }
                "ProjectV2ItemFieldLabelValue" {
                    $value = GetLabels -FieldNode $nodefield
                }
                "ProjectV2ItemFieldMilestoneValue" {
                    $value = $nodefield.milestone.title
                }
                "ProjectV2ItemFieldPullRequestValue" {
                    $value = GetPullRequests -FieldNode $nodefield
                }
                Default {
                    $value = $nodefield.text
                }
            }
            $item.$($nodefield.field.name) = $value

            # $item.$($nodefield.field.name) = $nodefield.name
        }

        try {
            $items.$itemId += $item
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

    $nodes = $ProjectV2.fields.nodes

    foreach($node in $nodes){
        $fieldId = $node.id

        $field = New-Object System.Collections.Hashtable
        $field.id = $node.id
        $field.name = $node.name
        $field.type = $node.__typename
        $field.dataType = $node.dataType

        if($field.type -eq "ProjectV2SingleSelectField"){
            $field.options = New-Object System.Collections.Hashtable
            foreach($option in $node.options){
                $field.options.$($option.name) = $option.id
            }
        }
        $fields.$fieldId = $field
    }

    return $fields
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

# function Convert-ItemFromResponse{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][object]$ProjectV2Item
#     )

#     $nodeItem = $ProjectV2Item

#     $item = New-Object System.Collections.Hashtable
#     $item.id = $nodeItem.id

#     # Content
#     $item.type = $nodeItem.content.__typename
#     $item.body = $nodeItem.content.body
#     # Title is stored in two places. in the content and as a field.
#     # We will use the field value
#     # $item.title = $nodeItem.content.title
#     $item.number = $nodeItem.content.number
#     $item.url = $nodeItem.content.url

#     # Populate content info based on item type
#     switch ($item.type) {
#         "Issue" {
#             $item.url = $nodeItem.content.url
#             }
#         Default {}
#     }

#     #Fields
#     foreach($nodefield in $nodeItem.fieldValues.nodes){
#         switch($nodefield.__typename){
#             "ProjectV2ItemFieldTextValue" {
#                 $value = $nodefield.text
#             }
#             "ProjectV2ItemFieldSingleSelectValue" {
#                 $value = $nodefield.name
#             }
#             "ProjectV2ItemFieldNumberValue" {
#                 $value = $nodefield.number
#             }
#             "ProjectV2ItemFieldDateValue" {
#                 $value = $nodefield.date
#             }
#             "ProjectV2ItemFieldUserValue" {
#                 $value = GetUsers -FieldNode $nodefield
#             }
#             "ProjectV2ItemFieldRepositoryValue" {
#                 $value = $nodefield.repository.url
#             }
#             "ProjectV2ItemFieldLabelValue" {
#                 $value = GetLabels -FieldNode $nodefield
#             }
#             "ProjectV2ItemFieldMilestoneValue" {
#                 $value = $nodefield.milestone.title
#             }
#             "ProjectV2ItemFieldPullRequestValue" {
#                 $value = GetPullRequests -FieldNode $nodefield
#             }
#             Default {
#                 $value = $nodefield.text
#             }
#         }
#         $item.$($nodefield.field.name) = $value

#         # $item.$($nodefield.field.name) = $nodefield.name
#     }

#     return $item

# }
