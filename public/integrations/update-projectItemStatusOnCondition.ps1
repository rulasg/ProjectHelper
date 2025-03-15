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
    Update-ProjectItemStatusOnDueDate -Owner "octodemo" -ProjectNumber 625 -DueDateFieldName "NCC" -Status "ActionRequired"
    This will update the status of project items for the owner "octodemo" and project number 625, setting the status to "ActionRequired" for items that are overdue based on the "NCC" field.
.NOTES
    Items changed are staged on the local database. Use Show-ProjectItemStaged to see the items staged. Use Save-ProjectItemStaged to save the changes to the project.
#>
function Update-ProjectItemStatusOnDueDate{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter(Position = 2)][string]$DueDateFieldName,
        [Parameter(Position = 3)][string]$Status,
        [Parameter()][switch]$Force
    )


    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get the project
    $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $itemKeys = $prj.items.Keys

    # filter keys that status is not done
    $itemKeys = $itemKeys | Where-Object {"Done" -ne $prj.items.$_.Status}

    # Filter keys that have due the DueDateFieldName
    $itemKeys = $itemKeys | Where-Object { $null -ne $prj.items.$_."NCC" }

    # Filter keys that have over due date
    $today = Get-Date -Format "yyyy-MM-dd"
    $itemKeys = $itemKeys | Where-Object {$today -ge $prj.items.$_.$DueDateFieldName}

    # Update status of the items
    foreach($key in $itemKeys){
        $params = @{
            ItemId = $key
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            FieldName = "Status"
            Value = $Status
        }
        Edit-ProjectItem @params
    }

} Export-ModuleMember -Function Update-ProjectItemStatusOnDueDate