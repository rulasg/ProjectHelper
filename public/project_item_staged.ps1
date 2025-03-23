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
function Test-ProjectItemStaged{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    return $(Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber)

} Export-ModuleMember -Function Test-ProjectItemStaged

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

    if(! $(Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
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
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Position = 2)][string]$Id
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project $Owner $ProjectNumber

    if([string]::IsNullOrWhiteSpace($Id)){
        
        # list all staged items

        $staged = $db.Staged

        if($staged.keys.count -eq 0){
            return
        }

        $itemsToShow = $staged.keys | Get-ItemStaged $db

        $ret = $itemsToShow | Select-Object -Property id, type, Title, `
             @{Name="FieldsCount"; Expression={$_.Fields.Count}}, `
             @{Name="FieldsName";Expression={$_.Fields.Name}}
    
    } else{

        # show a specific item

        $ret = @()
        
        $item = $db.Staged.$Id
        if($null -eq $item){
            return
        }
        
        $itemToShow = Get-ItemStaged $db $Id
        
        $itemToShow.Fields | ForEach-Object{
            $ret += [PSCustomObject]@{
                Name = $_.Name
                Value = $_.Value
                Before = $db.items.$Id.$($_.Name)
            }
        }
    }

    return $ret

 
} Export-ModuleMember -Function Show-ProjectItemStaged
