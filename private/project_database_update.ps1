
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

    $result = _GitHubProjectFields -Owner $Owner -Project $ProjectNumber

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

    foreach($nodeItem in $Response.items.nodes){
        $item = @{}
        $item.id = $nodeItem.id

        # Content
        $item.type = $nodeItem.content.__typename
        $item.title = $nodeItem.content.title
        $item.body = $nodeItem.content.body
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
                    $item.$($nodefield.field.name) = $nodefield.text
                }
                "ProjectV2ItemFieldSingleSelectValue" {
                    $item.$($nodefield.field.name) = $nodefield.name
                }
                "ProjectV2ItemFieldNumberValue" {
                    $item.$($nodefield.field.name) = $nodefield.number
                }
                "ProjectV2ItemFieldDateValue" {
                    $item.$($nodefield.field.name) = $nodefield.date
                }
                "ProjectV2ItemFieldUserValue" {
                    $item.$($nodefield.field.name) = GetUsers -FieldNode $nodefield
                }
                "ProjectV2ItemFieldRepositoryValue" {
                    $item.$($nodefield.field.name) = $nodefield.repository.url
                }
                "ProjectV2ItemFieldLabelValue" {
                    $item.$($nodefield.field.name) = GetLabels -FieldNode $nodefield
                }
                "ProjectV2ItemFieldMilestoneValue" {
                    $item.$($nodefield.field.name) = $nodefield.milestone.title
                }
                "ProjectV2ItemFieldPullRequestValue" {
                    $item.$($nodefield.field.name) = GetPullRequests -FieldNode $nodefield
                }
                Default {
                    $item.$($nodefield.field.name) = $nodefield.text
                }
            }

            $item.$($nodefield.field.name) = $nodefield.name
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

    foreach($node in $Response.fields.nodes){
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
    $ret = @()
    foreach($node in $FieldNode.users.nodes){
        $ret += $node.login
    }
    
    $ret = $ret | ConvertTo-Json

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