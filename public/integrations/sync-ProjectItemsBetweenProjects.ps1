

function Sync-ProjectItemsBetweenProjects {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)][string]$SourceOwner,
        [Parameter(Position = 1)][string]$SourceProjectNumber,
        [Parameter(Position = 2)][string]$DestinationOwner,
        [Parameter(Position = 3)][string]$DestinationProjectNumber,
        [Parameter(Mandatory)][object]$FieldsList,
        [Parameter()][string]$FieldSlug
    )

    # Get destination project for error handling and caching
    ($DestinationOwner,$DestinationProjectNumber) = Get-OwnerAndProjectNumber -Owner $DestinationOwner -ProjectNumber $DestinationProjectNumber
    if([string]::IsNullOrWhiteSpace($DestinationOwner) -or [string]::IsNullOrWhiteSpace($DestinationProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}
    $destinationProject = Get-Project -Owner $DestinationOwner -ProjectNumber $DestinationProjectNumber -Force

    # Get source project for error handling and caching
    ($SourceOwner,$SourceProjectNumber) = Get-OwnerAndProjectNumber -Owner $SourceOwner -ProjectNumber $SourceProjectNumber
    if([string]::IsNullOrWhiteSpace($SourceOwner) -or [string]::IsNullOrWhiteSpace($SourceProjectNumber)){ "Source Owner and ProjectNumber are required" | Write-MyError; return $null}
    $sourceProject = Get-Project -Owner $SourceOwner -ProjectNumber $SourceProjectNumber -Force

    # check if any of the projects are null
    if($null -eq $sourceProject -or $null -eq $destinationProject){
        "Source or Destination project not found" | Write-MyError
        return $null
    }

    # Check if all fields in fieldlist exist in the source project
    $sourceFields = $sourceProject.fields.Values
    $sourceFieldNames = $sourceFields | Select-Object -ExpandProperty name
    $missingFields = $FieldsList | Where-Object { $_ -notin $sourceFieldNames }
    if($missingFields.Count -gt 0){
        "The following fields are missing in the source project: $($missingFields -join ', ')" | Write-MyError
        return $null
    }

    # Get source project items
    $sourceItems = $sourceProject.items.Values
    foreach($sourceItem in $sourceItems){
        # Find matchin item destination project
        # Use URL
        # By the moment we are not going to sync Drafts as they belong to single project and therefore no matching is posible
        if($null -eq $sourceItem.url){
            "Item with no URL probably a draft. Skipping." | Write-MyVerbose
            continue
        }
        
        $destinationItem = $destinationProject.items.Values | Where-Object { $_.url -eq $sourceItem.url }
        if($null -eq $destinationItem){
            "Item with URL $($sourceItem.url) not found in destination project" | Write-MyVerbose
            continue
        }

        # Create hashtable with the values of the fields defined in $fieldlist
        $values = @{}
        foreach($field in $FieldsList){
            $values[$field] = $sourceItem.$field
        }

        # Check if values is empty or null
        $param = @{
            Owner = $destinationOwner
            ProjectNumber = $DestinationProjectNumber
            ItemId = $destinationItem.id
            Values = $values
            FieldSlug = $FieldSlug
        }
        Edit-ProjectItemWithValues  @param

    }
} Export-ModuleMember -Function Sync-ProjectItemsBetweenProjects