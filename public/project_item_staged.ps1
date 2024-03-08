<#
.SYNOPSIS
    Get the saved items from a project
.EXAMPLE
    Get-ProjectItemStaged -Owner "someOwner" -ProjectNumber 666
#>
function Get-ProjectItemStaged{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-ProjectDatabase $Owner $ProjectNumber

    return $db.Staged
} Export-ModuleMember -Function Get-ProjectItemStaged

<#
.SYNOPSIS
    Commits SAved changes in the DB to the project
#>
function Save-ProjectItemStaged{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    
    if(! $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Nothing to commit" | Write-MyHost
        return
    }

   $result = Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

   return $result

} Export-ModuleMember -Function Save-ProjectItemStaged
