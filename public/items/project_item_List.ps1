

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
    [Obsolete("Get-ProjectItemList is deprecated. Use Get-ProjectItems instead.")]
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
        } else {
            $db = $Project
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

