function MockCall_GitHubUpdateItemValues {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][string]$ProjectId,
        [parameter(Mandatory)][string]$ItemId,
        [parameter(Mandatory)][string]$FieldId,
        [parameter(Mandatory)][string]$Value,
        [parameter(Mandatory)][string]$Type,
        [parameter()][switch]$Async
    )

    $resultFile = "invoke-GitHubUpdateItemValue-$ItemId-$FieldId.json"

    $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'

    if ($Async) {
        $modulePath = $MODULE_PATH | split-path -Parent
        $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

        $command = 'Import-Module {modulepath} ; ' + $command
        $command = $command -replace '{modulepath}', $modulePath
    } 

    $command = $command -replace '{ProjectId}', $ProjectId
    $command = $command -replace '{ItemId}', $ItemId
    $command = $command -replace '{FieldId}', $FieldId
    $command = $command -replace '{Value}', $Value

    Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($ResultFile)" -Alias $command

}

function MockCall_GetItem{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][string]$ItemId
    )

    $command = "Invoke-GetItem -ItemId $ItemId"
    $resultFile = "invoke-getitem-$ItemId.json"

    Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($ResultFile)" -Alias $command
}