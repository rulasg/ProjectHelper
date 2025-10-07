<#
.SYNOPSIS
    Updates (stages) project item statuses based on a due date field.

.DESCRIPTION
    This cmdlet helps you maintain the status of project items based on a planning date field (e.g. 'DueDate', 'Target', etc.).
    The goal is set items to Action Required when due date is passed or reached, or set a Planned status if the due date is in the future.
    If items are closed (aka status "Done"), their due date is cleared.
    
    To achieve this objective here the loggig implemented:
    For each project item that has the specified due date field:
      - If the due date is today or in the past:
          * Change its status to the value in -StatusAction when its current status equals -StatusPlanned.
          * If -AnyStatus is specified, change any (non-done) item with a past/today due date to -StatusAction (except items filtered out or cleared as done).
      - If the due date is in the future and the current status equals -StatusAction, change it back to -StatusPlanned.
      - If -IncludeDoneItems is set, items whose status is exactly 'Done' have the due date field cleared (status is not modified).
      - If -StatusDone is provided, items whose status equals that value have the due date field cleared.
    It is an error to specify both -AnyStatus and -StatusDone.
    All edits are staged locally (not immediately pushed). Use Show-ProjectItemStaged, Save-ProjectItemStaged, or Reset-ProjectItemStaged as needed.

.PARAMETER Owner
    Owner of the project. Optional if a default context is configured.

.PARAMETER ProjectNumber
    Numeric project number. Optional if a default context is configured.

.PARAMETER StatusFieldName
    Name of the project field that holds the status value (e.g. 'Status').

.PARAMETER DateFieldName
    Name of the project field that stores the due / target date (must contain date values).

.PARAMETER StatusAction
    Status value that represents an actionable / ready state (e.g. 'ActionRequired').

.PARAMETER StatusPlanned
    Status value that represents a planned / future / scheduled state (e.g. 'Planned').

.PARAMETER StatusDone
    Optional alternate done-like status whose items should have their due date cleared (e.g. 'Cancelled', 'Won't Do').
    Cannot be used together with -AnyStatus.

.PARAMETER AnyStatus
    If specified, any item (except system Done or -StatusDone items cleared earlier) with a due date of today/past is moved to -StatusAction.
    Mutually exclusive with -StatusDone.

.PARAMETER IncludeDoneItems
    Include items whose status is exactly 'Done'. Their due date is cleared (status unchanged).

.PARAMETER Force
    Force refresh/sync of the project items content before processing. If not set will used project cached information if available.

.OUTPUTS
    None. Writes no output. All modifications are staged.

.EXAMPLE
    Update-ProjectItemsStatusOnDueDate -Owner octodemo -ProjectNumber 625 `
      -StatusFieldName Status -DateFieldName DueDate `
      -StatusAction ActionRequired -StatusPlanned Planned
    Moves overdue Planned items to ActionRequired; moves future ActionRequired items back to Planned.

.EXAMPLE
    Update-ProjectItemsStatusOnDueDate -StatusFieldName Status -DateFieldName Target `
      -StatusAction "In Progress" -StatusPlanned Planned -AnyStatus
    Forces every overdue item (except 'Done') into In Progress regardless of prior status.

.EXAMPLE
    Update-ProjectItemsStatusOnDueDate -StatusFieldName Status -DateFieldName Due `
      -StatusAction ActionRequired -StatusPlanned Planned -IncludeDoneItems
    Also clears Due on items already marked Done.

.EXAMPLE
    Update-ProjectItemsStatusOnDueDate -StatusFieldName Status -DateFieldName Due `
      -StatusAction ActionRequired -StatusPlanned Planned -StatusDone Cancelled
    Clears Due on items whose status is Cancelled (treating them as done-like).

.NOTES
    Throws if both -AnyStatus and -StatusDone are supplied. 
    Avoid conflict when item is in the past with the Specified Done Status. reopening closed items when Status Done and has Due field in the past.
    In this cases we could set to Action status or clear DueDate.
#>
function Update-ProjectItemsStatusOnDueDate{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][string]$StatusFieldName = "Status",
        [Parameter(Mandatory)][string]$DateFieldName,
        [Parameter(Mandatory)][string]$StatusAction,
        [Parameter(Mandatory)][string]$StatusPlanned,
        [Parameter()][string]$StatusDone,
        [Parameter()][switch]$AnyStatus,
        [Parameter()][switch]$IncludeDoneItems,
        [Parameter()][switch]$Force
    )

    "Updating project items status with due date for project $owner/$ProjectNumber" | Write-MyHost

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Sync project if needed
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $params = @{
        Owner = $Owner
        ProjectNumber = $ProjectNumber
        DateFieldName = $DateFieldName
        StatusFieldName = $StatusFieldName
        StatusAction = $StatusAction
        StatusPlanned = $StatusPlanned
        StatusDone = $StatusDone
        AnyStatus = $AnyStatus
        IncludeDoneItems = $IncludeDoneItems
    }

    # Call the injection type function
    $ret = Invoke-ProjectInjectionOnDueDate @params

    return $ret

} Export-ModuleMember -Function Update-ProjectItemsStatusOnDueDate

function Invoke-ProjectInjectionOnDueDate {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory)][string]$StatusFieldName,
        [Parameter(Mandatory)][string]$DateFieldName,
        [Parameter(Mandatory)][string]$StatusAction,
        [Parameter(Mandatory)][string]$StatusPlanned,
        [Parameter()][string]$StatusDone,
        [Parameter()][switch]$AnyStatus,
        [Parameter()][switch]$IncludeDoneItems
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -ExcludeDone:$(-Not $IncludeDoneItems)

    foreach($item in $items.Values){

        function EditItem($FieldName,$Value){
            $params = @{
                Owner = $Owner
                ProjectNumber = $ProjectNumber
                ItemId = $item.id
                FieldName = $FieldName
                Value = $Value
            }

            if ($PSCmdlet.ShouldProcess($item.Title, "edit to $FieldName [$Value]")) {
                Edit-ProjectItem @params
            }
        }

        # Skip if the item does not have the due date field
        if(-not $item.$DateFieldName){
            continue
        }

        # Skip if the item is not overdue
        $today = Get-DateToday
        $actualDate = $item.$DateFieldName
        $actualStatus = $item.Status

        # IncludeDoneItems --> Clear date on items that are system done
        if (($IncludeDoneItems) -and ($actualStatus -eq "Done")) {
            # Clear DueDate to done items
            EditItem $DateFieldName ""
            continue
        }

        $isPastOrToday = $actualDate -le $today
        $isFuture = ! $isPastOrToday
        $isActionRequired = $actualStatus -eq $StatusAction
        $isSetOtherDone = ! [string]::IsNullOrWhiteSpace($StatusDone)
        $isOtherDone = ($actualStatus -eq $StatusDone)

        # Clear date on items where status is $StatusDone
        if ($isSetOtherDone -and $isOtherDone ) {
            # Clear DueDate to done items
            EditItem $DateFieldName ""
            continue
        }

        # Move to StatusAction if today or due, and status is Planned or AnyStatus is set
        if ( $isPastOrToday -and (($actualStatus -eq $StatusPlanned) -or ($AnyStatus))){
            EditItem $StatusFieldName $StatusAction
            continue
        }

        # Move to Planned if ActionRequred but in the future
        if( $isFuture -and $isActionRequired){
            EditItem $StatusFieldName $StatusPlanned
            continue
        }
    }
} # Do not export this function to avoid conflicts with Update-ProjectItemsWithIntegration


