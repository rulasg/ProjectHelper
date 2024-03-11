function Get-ProjectFields{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Check if $db is null
    if($null -eq $db){
        "Project not found. Check owner and projectnumber" | Write-MyError
        return $null
    }

    # if $db is null it rill return null
    $fieldList = $db.fields.Values

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
        $ret = $Field | Select-Object -Property name,dataType

        return $ret
    }
}