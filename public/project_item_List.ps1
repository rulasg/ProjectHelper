

<#
.SYNOPSIS
Gets a list of project items from a GitHub project.

.DESCRIPTION
Retrieves all items from a GitHub project and returns them as a hashtable with ItemId as the key. 
Can optionally exclude items with status "Done".

.PARAMETER Owner
The owner of the GitHub repository containing the project.

.PARAMETER ProjectNumber
The project number in the repository.

.PARAMETER Project
An existing project object. If provided, Owner and ProjectNumber are not required.

.PARAMETER ExcludeDone
When specified, excludes items with status "Done" from the results.

.PARAMETER Force
Forces a refresh of the project data from GitHub.

.OUTPUTS
System.Collections.Hashtable
Returns a hashtable where keys are ItemIds and values are project item objects.

.EXAMPLE
Get-ProjectItemList -Owner "octocat" -ProjectNumber "1"
Gets all items from project 1 in the octocat organization.

.EXAMPLE
Get-ProjectItemList -Owner "octocat" -ProjectNumber "1" -ExcludeDone
Gets all items from project 1 excluding those with status "Done".
#>
function Get-ProjectItemList{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()][object]$Project,
        [Parameter()][switch]$ExcludeDone,
        [Parameter()][switch]$Force
    )

    try {
        # If Project is not provided, get it from Owner and ProjectNumber
        if(-not $Project){
            ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
            if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

            $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force
        }


        # Check if $db is null
        if($null -eq $db){
            "Project not found. Check owner and projectnumber" | Write-MyError
            return $null
        }

        #exclude done items if ExcludeDone is set
        if($ExcludeDone){
            $keys = $db.items.Keys | Where-Object { $db.items.$_.Status -ne "Done"}
        } else {
            $keys = $db.items.Keys
        }

        # Create a hashtable with ItemId as the key
        $ret = New-HashTable
        foreach ($key in $keys) {
            # ">> Getting item with ItemId [$key] from project [$ProjectNumber] for owner [$Owner]" | Write-MyHost
            # $item = Get-ProjectItem -ItemId $key -Owner $Owner -ProjectNumber $ProjectNumber
            $item = Get-Item $db $key
            # "<< Get-ProjectItem returned: $($item | Out-String)" | Write-MyHost

            if ($null -ne $item) {
                $ret[$key] = $item
            }
        }

        return $ret
    }  catch {
        "Can not get item list with Force [$Force]; $_" | Write-MyError
    }

} Export-ModuleMember -Function Get-ProjectItemList

function Test-ItemIsDone($Item){

    $ret = $Item.Status -eq "Done"

    return $ret
}

<#
.SYNOPSIS
Finds project items by exact title match.

.DESCRIPTION
Searches for project items that have an exact title match (case-insensitive). 
Returns all items that match the specified title.

.PARAMETER Title
The exact title to search for. The comparison is case-insensitive and trims whitespace.

.PARAMETER Owner
The owner of the GitHub repository containing the project.

.PARAMETER ProjectNumber
The project number in the repository.

.PARAMETER Force
Forces a refresh of the project data from GitHub.

.OUTPUTS
System.Object[]
Returns an array of project item objects that match the title.

.EXAMPLE
Find-ProjectItemByTitle -Title "Bug Fix" -Owner "octocat" -ProjectNumber "1"
Finds all items in project 1 with the exact title "Bug Fix".
#>
function Find-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Title,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$ProjectNumber,
        [Parameter()] [switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $items){ return $null }

    $ret =  $items.Values | Where-Object { $_.Title.Trim().ToLower() -eq $($Title.Trim().ToLower()) }

    return $ret

} Export-ModuleMember -Function Find-ProjectItemByTitle

function Search-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $items){ return $null}

    $ret = $items.Values | Where-Object { $_.Title -like "*$Title*" }

    return $ret

} Export-ModuleMember -Function Search-ProjectItemByTitle

function Search-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$filter,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string[]]$Fields,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $Fields = Get-EnvironmentDisplayFields -Fields $Fields

    $itemList = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    if($null -eq $itemList){ return $null}

    $itemListValues = $itemList.Values | FilterItems -Filter $filter

    $items = $itemListValues | ConvertToItemDisplay -Fields $Fields

    Write-MyHost
    "Filter: $filter" | Write-MyHost
    Write-MyHost

    return $items

} Export-ModuleMember -Function Search-ProjectItem

# TODO !! - Figure a way to show table always