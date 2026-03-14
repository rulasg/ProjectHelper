<#
.SYNOPSIS
    Update all the items of a project with an integration command
.DESCRIPTION
    Update all the items of a project with an integration command
    The function will update all the items of a project with the values returned by the integration command
    The integration command will be called for each Item with the value of the integration field as parameter.
    The integration command must return a hashtable with the values to be updated
    The project fields to be updated will have the same name as the hash table keys with a slug as suffix
    If an item has a field with the name `sf_Name` it will be updated with the value of the hashtable key Name if the slug defined is "sf_"
.EXAMPLE
    Update-ProjectItemsWithIntegration -Owner "someOwner" -ProjectNumber 164 -IntegrationField "sfUrl" -IntegrationCommand "Get-SfAccount" -Slug "sf_"
#>
function Update-ProjectItemsWithIntegration{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Mandatory)][string]$IntegrationField,
        [Parameter(Mandatory)][string]$IntegrationCommand,
        [Parameter()] [string]$Slug,
        [Parameter()] [switch]$IncludeDoneItems,
        [Parameter()] [int32]$CommitMaxItems = -1
    )
    ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $params = @{
        Owner = $Owner
        ProjectNumber = $ProjectNumber
        IntegrationField = $IntegrationField
        IntegrationCommand = $IntegrationCommand
        Slug = $Slug
        IncludeDoneItems = $IncludeDoneItems
        CommitMaxItems = $CommitMaxItems
    }
    # Call the injection type function
    $ret = Invoke-ProjectInjectionWithIntegration @params

    return $ret

} Export-ModuleMember -Function Update-ProjectItemsWithIntegration

function Invoke-ProjectInjectionWithIntegration{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$IntegrationField,
        [Parameter(Mandatory)][string]$IntegrationCommand,
        [Parameter()] [string]$Slug,
        [Parameter()] [switch]$IncludeDoneItems,
        [Parameter()] [int32]$CommitMaxItems = -1
    )

    ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $updateCount = 0

    $items = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber -IncludeDone:$IncludeDoneItems

    $Fields = Get-ProjectFields -Owner $owner -ProjectNumber $projectNumber

    foreach($item in $items){

        $params = @{
            Owner = $owner
            ProjectNumber = $projectNumber
            Item = $item
            Fields = $Fields
            IntegrationField = $IntegrationField
            IntegrationCommand = $IntegrationCommand
            Slug = $Slug
        }
        Invoke-ProjectRecordUpdateWithIntegration @params

        # Check for commit every $CommitMaxItems updates to avoid having too many staged items in memory. If $CommitMaxItems is -1, it will not commit until all items are processed.
        $stagedcount = (Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber).Values.Count
        if( $stagedcount -ge $CommitMaxItems -and $CommitMaxItems -ne -1){
            "[Update-ProjectItemsWithIntegration] Committing staged items before continue updating. Staged count: $stagedcount" | Write-MyDebug -section "Integration"
            Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
        } else {
            "[Update-ProjectItemsWithIntegration] Count $updateCount / $CommitMaxItems" | Write-MyDebug -section "Integration"
        }
    }

    # Sync the last staged items
    if($CommitMaxItems -ne -1){
        "[Update-ProjectItemsWithIntegration] Committing staged items at the end of the process" | Write-MyDebug -section "Integration"
        Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
    }
} # Do not export this function to avoid conflicts with Update-ProjectItemsWithIntegration

function Invoke-ProjectRecordUpdateWithIntegration{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter(Mandatory)][object]$Item,
        [Parameter(Mandatory)][object]$Fields,
        [Parameter(Mandatory)][string]$IntegrationField,
        [Parameter(Mandatory)][string]$IntegrationCommand,
        [Parameter()] [string]$Slug
    )

        # Skip if the item does not have the integration field
        if(-not $item.$IntegrationField){
            "[Invoke-ProjectRecordUpdateWithIntegration] $($item.id) does not have the integration field $IntegrationField, skipping" | Write-MyDebug -section "Integration"
            continue
        }

        try {
            "Calling integration - $IntegrationCommand $($item.$IntegrationField)]" | Write-MyHost
            $command = $IntegrationCommand + " " + '"{key}"'
            $command = $command -replace '{key}', $item.$IntegrationField
            $values = Invoke-MyCommand -Command $command
        }
        catch {
            "[Invoke-ProjectRecordUpdateWithIntegration] Something went wrong with the integration command for $($item.id)" | Write-Error
        }
        # Call the ingetration Command with the integration field value as parameter

        Write-MyDebug "[Invoke-ProjectRecordUpdateWithIntegration] Values" -Section "Integration" -Object $values
        
        # Check if Values is empty or null
        if($null -eq $values -or $values.Count -eq 0){
            "[Invoke-ProjectRecordUpdateWithIntegration] No values returned from the integration command for $($item.id)" | Write-Mydebug -section "Integration"
            continue
        }
        
        # Edit item with the value
        $param = @{
            Owner = $owner
            ProjectNumber = $projectNumber
            ItemId = $item.id
            Values = $values
            FieldSlug = $Slug
            Fields = $Fields
        }
        
        Write-MyDebug "[Invoke-ProjectRecordUpdateWithIntegration] >> Edit-ProjectItemWithValues [$($fields.Count)]" -Section "Integration"
        Edit-ProjectItemWithValues @param
        Write-MyDebug "[Invoke-ProjectRecordUpdateWithIntegration] << Edit-ProjectItemWithValues [$($fields.Count)]" -Section "Integration"

}