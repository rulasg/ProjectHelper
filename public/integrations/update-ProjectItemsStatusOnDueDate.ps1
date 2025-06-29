<#
.SYNOPSIS
    Update the status of project items if they are overdue.
.DESCRIPTION
    This function updates the status of project items if they are overdue based on a specific field.
.PARAMETER Owner
    The owner of the project.
.PARAMETER ProjectNumber
    The project number.
.PARAMETER DueDateFieldName
    The name of the field that contains the due date.
.PARAMETER Status
    The status to set for the project items that have overdued.
.PARAMETER Force
    Force to read the actual status of the project.
.EXAMPLE
    Update-ProjectItemsStatusOnDueDate -Owner "octodemo" -ProjectNumber 625 -DueDateFieldName "NCC" -Status "ActionRequired"
    This will update the status of project items for the owner "octodemo" and project number 625, setting the status to "ActionRequired" for items that are overdue based on the "NCC" field.
.NOTES
    Items changed are staged on the local database. Use Show-ProjectItemStaged to see the items staged. Use Save-ProjectItemStaged to save the changes to the project.
#>
function Update-ProjectItemsStatusOnDueDate{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][string]$DueDateFieldName,
        [Parameter()][string]$Status,
        [Parameter()][switch]$IncludeDoneItems,
        [Parameter()] [switch]$Force

    )

    "Updating project items status with due date for project $owner/$ProjectNumber" | Write-MyHost

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if((-not $SkipProjectSync) -AND (Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Project has staged items, please Sync-ProjectItemStaged or Reset-ProjectItemStaged and try again" | Write-Error
        return
    }

    # Sync project if needed
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Call the injection type function
    $ret = Invoke-ProjectInjectionOnDueDate -Owner $Owner -ProjectNumber $ProjectNumber -DueDateFieldName $DueDateFieldName -Status $Status -IncludeDoneItems:$IncludeDoneItems

    return $ret

} Export-ModuleMember -Function Update-ProjectItemsStatusOnDueDate

function Invoke-ProjectInjectionOnDueDate {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][string]$DueDateFieldName,
        [Parameter()][string]$Status,
        [Parameter()][switch]$IncludeDoneItems
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -ExcludeDone:$(-Not $IncludeDoneItems)

    foreach($item in $items.Values){

        # Skip if the item does not have the due date field
        if(-not $item.$DueDateFieldName){
            continue
        }

        # Skip if the item is not overdue
        $today = Get-DateToday
        if($today -lt $item.$DueDateFieldName){
            continue
        }

        # Change item

        # Update status of the items
        $params = @{
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            ItemId = $item.id
            FieldName = "Status"
            Value = $Status
        }
        Edit-ProjectItem @params
    }
} # Do not export this function to avoid conflicts with Update-ProjectItemsWithIntegration