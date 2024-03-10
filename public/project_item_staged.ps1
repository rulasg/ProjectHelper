<#
.SYNOPSIS
    Get the saved items from a project
.EXAMPLE
    Get-ProjectItemStaged -Owner "someOwner" -ProjectNumber 164
#>
function Get-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-ProjectDatabase $Owner $ProjectNumber

    $ret = $db.Staged

    return $ret
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
        [Parameter(Position = 1)][string]$ProjectNumber
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if(! $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Nothing to commit" | Write-MyHost
        return
    }

   $result = Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

   return $result

} Export-ModuleMember -Function Save-ProjectItemStaged

<#
.SYNOPSIS
    Discards the staged changes
#>
function Reset-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-ProjectDatabase $Owner $ProjectNumber

    $db.Staged = $null

} Export-ModuleMember -Function Reset-ProjectItemStaged
