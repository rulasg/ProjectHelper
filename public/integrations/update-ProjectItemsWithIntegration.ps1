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
        [Parameter()] [switch]$SkipStagedCheck

    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if((-not $SkipStagedCheck) -AND (Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Project has staged items, please Sync-ProjectItemStaged or Reset-ProjectItemStaged and try again" | Write-Error
        return
    }

    # Sync project if needed
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Call the injection type function
    $ret = Invoke-ProjectInjectionWithIntegration -Owner $Owner -ProjectNumber $ProjectNumber -IntegrationField $IntegrationField -IntegrationCommand $IntegrationCommand -Slug $Slug -IncludeDoneItems:$IncludeDoneItems

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
        [Parameter()] [switch]$IncludeDoneItems
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -ExcludeDone:$(-not $IncludeDoneItems)

    foreach($item in $items.Values){

        # Skip if the item does not have the integration field
        if(-not $item.$IntegrationField){
            "Item $($item.id) does not have the integration field $IntegrationField, skipping" | Write-MyVerbose
            continue
        }

        try {
            "Calling integration [ $IntegrationCommand $($item.$IntegrationField)]" | Write-MyHost
            $command = $IntegrationCommand + " " + '"{key}"'
            $command = $command -replace '{key}', $item.$IntegrationField
            $values = Invoke-MyCommand -Command $command
        }
        catch {
            "Something went wrong with the integration command for $($item.id)" | Write-Error
        }
        # Call the ingetration Command with the integration field value as parameter

        # Check if Values is empty or null
        if($null -eq $values -or $values.Count -eq 0){
            "No values returned from the integration command for $($item.id)" | Write-MyVerbose
            continue
        }

        # Edit item with the value
        $param = @{
            Owner = $owner
            ProjectNumber = $projectNumber
            ItemId = $item.id
            Values = $values
            FieldSlug = $Slug
        }

        Edit-ProjectItemWithValues @param
    }
} # Do not export this function to avoid conflicts with Update-ProjectItemsWithIntegration