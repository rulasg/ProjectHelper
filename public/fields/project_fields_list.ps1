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

    ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $fieldList = getFieldsCache -Owner $Owner -ProjectNumber $ProjectNumber

    if(-Not $fieldList -or $Force){

        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems
        
        # Check if $db is null
        if($null -eq $db){
            "Project not found. Check owner and projectnumber" | Write-MyError
            return $null
        }
        
        # if $db is null it rill return null
        $fieldList = $db.fields.Values

        setFieldsCache -Owner $Owner -ProjectNumber $ProjectNumber -FieldList $fieldList
    }

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

$script:fieldsCache = @{}

function getFieldsCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$Owner,
        [Parameter(Mandatory,Position = 1)][string]$ProjectNumber
    )

    $key = "$Owner-$ProjectNumber"
    $lockKey = Get-DatabaseKey $Owner $ProjectNumber "field-cachelock"

    $lock = Get-Database -Key $lockKey
    $cache = $script:fieldsCache[$key]

    if($lock -cne $cache.SafeId) {
        $script:fieldsCache.Remove($key)
        return $null
    }

    return $cache.List
}

function setFieldsCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$Owner,
        [Parameter(Mandatory,Position = 1)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 2)][object]$FieldList
    )

    $key = "$Owner-$ProjectNumber"
    $lockKey = Get-DatabaseKey $Owner $ProjectNumber "field-cachelock"

    $safeId = [Guid]::NewGuid().ToString()

    # Save safeId to field-lock
    Save-Database -Database $safeId -Key $lockKey

     # Set lock in database to prevent concurrent updates
    $script:fieldsCache[$key] = @{
        List = $FieldList
        SafeId = $safeId
    }
}