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

    $db = Get-Project $Owner $ProjectNumber

    $ret = $db.Staged

    return $ret
} Export-ModuleMember -Function Get-ProjectItemStaged

<#
.SYNOPSIS
    Commits SAved changes in the DB to the project
#>
function Sync-ProjectItemStaged{
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

   $result = Sync-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

   return $result

} Export-ModuleMember -Function Sync-ProjectItemStaged

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

    $dbkey = GetDatabaseKey -Owner $Owner -ProjectNumber $ProjectNumber
    $db = Get-Project $Owner $ProjectNumber

    $db.Staged = $null
    Save-Database -Key $dbkey -Database $db

} Export-ModuleMember -Function Reset-ProjectItemStaged

function Show-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project $Owner $ProjectNumber

    $staged = $db.Staged

    if($staged.keys.count -eq 0){
        return
    }

    $ret = $staged.keys | Get-ItemStaged $db

    return $ret
 
} Export-ModuleMember -Function Show-ProjectItemStaged
