<#
.SYNOPSIS
    Syncs project items fields between two projects.
.DESCRIPTION
    This function syncs project items fields between two projects.
    It will download both projects and compare the items fields by name using slug prefix in destination used. (See FieldSlug parameter).
    The function will only update the fields that are defined in the FieldsList parameter.
    Changes will be commited to the module project staging area. Use `Show-ProjectItemStaged`to see the changes. Use `Sync-ProjectItemStaged` to commit the changes to the destination project.

.PARAMETER SourceOwner
    The owner of the source project.
.PARAMETER SourceProjectNumber
    The project number of the source project.
.PARAMETER DestinationOwner
    The owner of the destination project.
.PARAMETER DestinationProjectNumber
    The project number of the destination project.
.PARAMETER FieldsList
    The list of fields to sync between the source and destination projects.
.PARAMETER FieldSlug
    The slug to use for the fields in the destination project.
    Slug is the prefix of the field name in the destination project.
.PARAMETER ForceDestination
    If specified, will not force a refresh of the destination project from the server.
    Use this parameter when you know the destination project is already cached locally with the correct.
.PARAMETER ForceSource
    If specified, will not force a refresh of the source project from the server.
    Use this parameter when you know the source project is already cached locally.
.PARAMETER IncludeDoneItems
    If specified, will include items marked as done in the sync process.
.EXAMPLE
    Sync-ProjectItemsbetweenProjects -SourceOwner github -DestinationOwner github -SourceProjectNumber $oaProject -DestinationProjectNumber $rlProject -FieldsList @("Focus","Country") -FieldSlug "oa_"
    #>
function Update-ProjectItemsBetweenProjects {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)][string]$SourceOwner,
        [Parameter(Mandatory,Position = 1)][string]$SourceProjectNumber,
        [Parameter(Position = 2)][string]$DestinationOwner,
        [Parameter(Position = 3)][string]$DestinationProjectNumber,
        [Parameter()][string]$FieldSlug,
        [Parameter()][switch]$IncludeDoneItems,
        [Parameter()][switch]$ForceDestination,
        [Parameter()][switch]$ForceSource
    )

    # Get source project before destination to avoid project infor environment caching
    ($SourceOwner,$SourceProjectNumber) = Resolve-ProjectParameters -Owner $SourceOwner -ProjectNumber $SourceProjectNumber -DoNotThrow
    $sourceProject = Get-Project -Owner $SourceOwner -ProjectNumber $SourceProjectNumber -Force:$ForceSource

    # Get destination project for error handling and caching
    ($DestinationOwner,$DestinationProjectNumber) = Resolve-ProjectParameters -Owner $DestinationOwner -ProjectNumber $DestinationProjectNumber -DoNotThrow
    $destinationProject = Get-Project -Owner $DestinationOwner -ProjectNumber $DestinationProjectNumber -Force:$ForceDestination

    # check if any of the projects are null
    if($null -eq $sourceProject -or $null -eq $destinationProject){
        "Source or Destination project not found" | Write-MyError
        return $null
    }

    # Check all the fields on the source project
    $FieldsList = $sourceProject.fields.Values.name

    # Get source project items
    $sourceItems = Get-ProjectItems -Owner $SourceOwner -ProjectNumber $SourceProjectNumber -IncludeDone:$IncludeDoneItems

    # Process each item in the source project
    foreach($sourceItem in $sourceItems){
        # Find matching item in destination project
        # Use URL
        # By the moment we are not going to sync Drafts as they belong to single project and therefore no matching is possible
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
            $values.$field = $sourceItem.$field
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
} Export-ModuleMember -Function Update-ProjectItemsBetweenProjects