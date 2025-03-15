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
        [Parameter()] [string]$Slug
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project
    $project = Get-Project -Owner $owner -ProjectNumber $projectNumber -Force


    # Extract all items that have value on the integration field.
    # This field is the value that will work as parameter to the integration command
    $itemList = $project.items.Values | Where-Object { -Not [string]::IsNullOrWhiteSpace($_.$IntegrationField) }
    "Items with $IntegrationField value to update: $($itemList.Count)" | Write-MyHost

    foreach($item in $itemList){
        
        try {
            "Calling integration [ $IntegrationCommand $($item.$IntegrationField)]" | Write-MyHost
            $values = Invoke-MyCommand -Command "$IntegrationCommand $($item.$IntegrationField)"
        }
        catch {
            "Something went wrong with the integration command for $($item.id)" | Write-Error
        }
        # Call the ingetration Command with the integration field value as parameter

        # Check if Values is empty or null
        if($null -eq $values -or $values.Count -eq 0){
            "No values returned from the integration commandfor $($item.id)" | Write-MyWarning
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

} Export-ModuleMember -Function Update-ProjectItemsWithIntegration