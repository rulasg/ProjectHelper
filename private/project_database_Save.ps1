
Set-MyInvokeCommandAlias -Alias GitHubSaveProjectItem -Command "gh project item-edit --id {idemid} --field-id {fieldid} --project-id {projectid} {valueparameter}"

function Save-ProjectDatabase{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    foreach($idemId in $db.Staged.Keys){
        foreach($fieldId in $db.staged.$idemId.Keys){
            "Saving $item.Id $field.Id $field.Value" | Write-MyHost

            $item_id = $idemId
            $field_id = $fieldId

        }
        
    }
}

<#
.SYNOPSIS
    Save a field in a project item
#>
function Save-ItemField{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)][string]$ProjectId,
        [Parameter(Mandatory,Position=1)][string]$FieldId,
        [Parameter(Mandatory,Position=2)][string]$ItemId,
        [Parameter()][string]$Number,
        [Parameter()][string]$Text,
        [Parameter()][string]$OptionId
    )

    $command = 'gh project item-edit --id {itemid} --field-id {fieldid} --project-id {projectid}'
    
    if(-not [string]::IsNullOrWhiteSpace($Number)){
        $command = $command + " --number $number "
    }

    if(-not [string]::IsNullOrWhiteSpace($Text)){
        $command = $command + " --text $text "
    }

    if(-not [string]::IsNullOrWhiteSpace($OptionId)){
        $command = $command + " --single-select-option-id $OptionId "
    }

    $command = $command -replace "{itemid}", $itemId
    $command = $command -replace "{fieldid}", $fieldId
    $command = $command -replace "{projectid}", $projectId
    $command = $command -replace "{value}", $Value
    
    "Updating item [{0}]" -f $item.title | Write-MyVerbose

    if ($PSCmdlet.ShouldProcess($item.tittle, $command)) {
        $command | Write-MyVerbose
        $result = Invoke-Expression $command
    }

    return $result

} Export-ModuleMember -Function Edit-ItemField