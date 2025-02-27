
Set-MyInvokeCommandAlias -Alias GitHub_UpdateProjectV2ItemFieldValue -Command 'Invoke-GitHubUpdateItemValues -ProjectId {projectid} -ItemId {itemid} -FieldId {fieldid} -Value "{value}" -Type {type}'

function Sync-ProjectDatabase{
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

    $db = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

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
                return $false
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

    # Check that all values are updated before cleanring staging
    $different = @{}
    foreach($idemId in $db.Staged.Keys){
        foreach($fieldId in $db.Staged.$idemId.Keys){
            $fieldName = $db.fields.$fieldId.name

            $stagedV = $db.Staged.$idemId.$fieldId.Value
            $actualV = $db.items.$idemId.$fieldName

            if(!($stagedV -eq $actualV)){
                $diff = @{
                    Id = $idemId
                    Field = $fieldId
                    Staged = $stagedV
                    Actual = $actualV
                }
                $different.$itemId = $diff
            }

        }
    }

    if($different.Count -eq 0){
        $db.Staged = $null
        Save-Database -Key $dbkey -Database $db
        return $true
    } else {
        "Error: Staged values are not equal to actual values" | Write-MyError
        $different | convertto-json | Write-MyError
        return $false
    }

}

# function Set-ProjectV2Item2Database {
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][object]$Database,
#         [Parameter(Position = 1)][object]$projectV2Item,
#         [Parameter(Position = 2)][Object]$Item
#     )

#     $itemId = $Projectv2item.id

#     foreach($field in $item.keys){
#         $Database.items.$itemId.$field = $item.$field
#     }
# }

function ConvertTo-UpdateType{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$DataType
    )

            # [ValidateSet("singleSelectOptionId", "text", "number", "date", "iterationId")]

    switch ($DataType) {
        "TEXT"           { $ret = "text"                 ;Break }
        "TITLE"          { $ret = "text"                 ;Break }
        "NUMBER"         { $ret = "number"               ; Break}
        "DATE"           { $ret = "date"                 ; Break}
        "iterationId"    { $ret = "iterationId"          ; Break}
        "SINGLE_SELECT"  { $ret = "singleSelectOptionId" ;Break }

        default          { $ret = $null }
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
