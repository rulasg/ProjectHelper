# We need to invoke a call back to allow the mock of this call on testing
Set-MyInvokeCommandAlias -Alias GitHubOrgProjectWithFields -Command "Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber}"

function Update-ProjectDatabase {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }

    # check if there are unsaved changes
    $saved = Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber
    if($saved -and -Not $Force){
        throw "There are unsaved changes. Restore changes with Reset-ProjectItemStaged or sync projects with Sync-ProjectItemStaged first and try again"
    }

    $result  = Invoke-MyCommand -Command GitHubOrgProjectWithFields -Parameters $params

    # check if the result is empty
    if($null -eq $result){
        "Updating ProjectDatabase for project [$Owner/$ProjectNumber]" | Write-MyError
        return $false
    }

    $projectV2 = $result.data.organization.ProjectV2

    $items = Convert-ItemsFromResponse $projectV2
    $fields = Convert-FieldsFromReponse $projectV2

    # Set-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Items $items -Fields $fields
    Set-ProjectDatabaseV2 $projectV2 -Items $items -Fields $fields

    return $true
}

function Convert-ItemsFromResponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2
    )
    $items = @{}

    $nodes = $ProjectV2.items.nodes

    foreach($nodeItem in $nodes){

        $itemId = $nodeItem.id

        # TODO !! - Refactor to call Convert-ItemFromResponse for each node utem

        $item = @{}
        $item.id = $itemId

        # Content
        $item.type = $nodeItem.content.__typename
        $item.body = $nodeItem.content.body
        # Title is stored in two places. in the content and as a field.
        # We will use the field value
        # $item.title = $nodeItem.content.title
        $item.number = $nodeItem.content.number
        $item.url = $nodeItem.content.url

        # Populate content info based on item type
        switch ($item.type) {
            "Issue" {
                $item.url = $nodeItem.content.url
             }
            Default {}
        }

        #Fields
        foreach($nodefield in $nodeItem.fieldValues.nodes){
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

        $items.$itemId += $item
    }
    return $Items
}

function Convert-FieldsFromReponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2
    )
    $fields = @{}

    $nodes = $ProjectV2.fields.nodes

    foreach($node in $nodes){
        $fieldId = $node.id

        $field = @{}
        $field.id = $node.id
        $field.name = $node.name
        $field.type = $node.__typename
        $field.dataType = $node.dataType

        if($field.type -eq "ProjectV2SingleSelectField"){
            $field.options = @{}
            foreach($option in $node.options){
                $field.options.$($option.name) = $option.id
            }
        }
        $fields.$fieldId = $field
    }

    return $fields
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

function Convert-ItemFromResponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$ProjectV2Item
    )

    $nodeItem = $ProjectV2Item

    $item = @{}
    $item.id = $nodeItem.id

    # Content
    $item.type = $nodeItem.content.__typename
    $item.body = $nodeItem.content.body
    # Title is stored in two places. in the content and as a field.
    # We will use the field value
    # $item.title = $nodeItem.content.title
    $item.number = $nodeItem.content.number
    $item.url = $nodeItem.content.url

    # Populate content info based on item type
    switch ($item.type) {
        "Issue" {
            $item.url = $nodeItem.content.url
            }
        Default {}
    }

    #Fields
    foreach($nodefield in $nodeItem.fieldValues.nodes){
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

    return $item

}
