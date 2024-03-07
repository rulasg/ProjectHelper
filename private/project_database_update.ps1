
function Update-ProjectDatabase {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $items = Get-ItemsList -Owner $Owner -ProjectNumber $ProjectNumber
    $fields = Get-FieldList -Owner $Owner -ProjectNumber $ProjectNumber

    Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Items $items -Fields $fields
}

function Update-ProjectDatabase2 {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $result = Invoke-GitHubOrgProjectWithFields -Owner $Owner -Project $ProjectNumber

    $items = Convert-ItemsFromResponse $result
    $fields = Convert-FieldsFromReponse $result

    Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Items $items -Fields $fields
}

function Convert-ItemsFromResponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Response
    )
    $items = @()

    $nodes = $Response.data.organization.projectV2.items.nodes

    foreach($nodeItem in $nodes){
        $item = @{}
        $item.id = $nodeItem.id

        # Content
        $item.type = $nodeItem.content.__typename
        $item.title = $nodeItem.content.title
        $item.body = $nodeItem.content.body

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

        $items += $item
    }
    return $Items
}

function Convert-FieldsFromReponse{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Response
    )
    $fields = @()

    $nodes = $Response.data.organization.projectV2.fields.nodes

    foreach($node in $nodes){
        $field = @{}
        $field.id = $node.id
        $field.name = $node.name
        $field.type = $node.__typename
        $field.dataTYpe = $node.dataType

        if($field.type -eq "ProjectV2SingleSelectField"){
            $field.options = @{}
            foreach($option in $node.options){
                $field.options.$($option.name) = $option.id
            }
        }
        $fields += $field
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