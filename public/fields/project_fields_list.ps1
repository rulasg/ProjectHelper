<#
.SYNOPSIS
Gets the list of fields available in a GitHub project.

.DESCRIPTION
Retrieves all custom fields defined in a GitHub project and returns them formatted for display.
Can optionally filter fields by name using wildcard matching.

.PARAMETER Owner
The owner of the GitHub repository containing the project.

.PARAMETER ProjectNumber
The project number in the repository.

.PARAMETER Name
Optional filter to search for fields containing the specified text in their name.

.PARAMETER Force
Forces a refresh of the project data from GitHub.

.OUTPUTS
System.Object[]
Returns an array of project field objects with name, dataType, and additional information.

.EXAMPLE
Get-ProjectFields -Owner "octocat" -ProjectNumber "1"
Gets all fields from project 1 in the octocat repository.

.EXAMPLE
Get-ProjectFields -Owner "octocat" -ProjectNumber "1" -Name "status"
Gets all fields from project 1 that contain "status" in their name.
#>
function Get-ProjectFields{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$ProjectNumber,
        [Parameter(Position = 0)][string]$Name,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems

    # Check if $db is null
    if($null -eq $db){
        "Project not found. Check owner and projectnumber" | Write-MyError
        return $null
    }

    # if $db is null it rill return null
    $fieldList = $db.fields.Values

    # if name
    if($Name){
        # Filter fields by name
        $fieldList = $fieldList | Where-Object { $_.name -like "*$Name*" }
    }

    # return if #db is null
    if($null -eq $fieldList){ return $null}

    $fields = $fieldList | ConvertToFieldDisplay

    $fields = $fields | Sort-Object -Property dataType

    return $fields

} Export-ModuleMember -Function Get-ProjectFields

function ConvertToFieldDisplay{
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object]$Field
    )

    process{
        # Initialize moreInfo as null
        $moreInfo = $null

        # Use switch to determine moreInfo based on dataType
        switch ($Field.dataType) {
            "SINGLE_SELECT" {
                $moreInfo = $Field.options.keys
            }
            "ITERATION" {
                        $moreInfo = $Field.options.keys
            }
        }

        # Create custom object with all properties
        $ret = [PSCustomObject]@{
            name = $Field.name
            dataType = $Field.dataType
            MoreInfo = $moreInfo
        }

        return $ret
    }
}