function Get-ProjectFields{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()][string]$Name,
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