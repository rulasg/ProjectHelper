<#
.SYNOPSIS
    Get the saved items from a project
.EXAMPLE
    Get-ProjectItemStaged -Owner "someOwner" -ProjectNumber 164
#>
function Get-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project $Owner $ProjectNumber -SkipItems

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
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
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
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
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

<#.SYNOPSIS
    Commits SAved changes in the DB to the project asynchronously
#>
function Sync-ProjectItemStagedAsync{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][int]$SyncBatchSize = 30
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if(! $(Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Nothing to commit" | Write-MyHost
        return $true
    }

   $result = Sync-ProjectDatabaseAsync -Owner $Owner -ProjectNumber $ProjectNumber -SyncBatchSize $SyncBatchSize

   return $result

} Export-ModuleMember -Function Sync-ProjectItemStagedAsync


<#
.SYNOPSIS
    Discards the staged changes
#>
function Reset-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project $Owner $ProjectNumber

    $db.Staged = $null

    Save-ProjectDatabaseSafe -Database $db

} Export-ModuleMember -Function Reset-ProjectItemStaged

function Show-ProjectItemStaged{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Id
    )

    begin{
        ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

        $db = Get-Project $Owner $ProjectNumber
    }

    process {

        if([string]::IsNullOrWhiteSpace($Id)){

            # list all staged items

            $staged = $db.Staged

            if($staged.keys.count -eq 0){
                return
            }

            $ret = @()

            foreach($itemKey in $staged.keys){
                $stagedItem = Get-ItemStaged $db $itemKey
                $item = Get-Item $db $itemKey

                $itemToShow = @{}
                $itemToShow.Id = $itemKey
                # $itemToShow.type = $item.type
                $itemToShow.Title = $item.Title
                # $itemToShow.FieldsCount = $stagedItem.Count
                $itemToShow.FieldsName = $stagedItem.Keys
                # $itemToShow.Fields = @{}
                # foreach($field in $staged.Keys){
                    #     $itemToShow.Fields = [PSCustomObject]@{
                        #         Value = $staged.$field
                        #         Before = $item.$field
                        #     }
                        # }

                $ret += [PSCustomObject] $itemToShow
            }
        } else {

            # show a specific item

            $ret = @()

            $item = $db.Staged.$Id
            if($null -eq $item){
                return
            }

            $staged = Get-ItemStaged $db $Id
            $item = $db.items.$Id

            $ret = @{}

            foreach($key in $staged.Keys){
                $ret.$key = [PSCustomObject]@{
                    Value =  $staged.$key
                    Before = $item.$key
                }
            }

        }

        return $ret
    }

} Export-ModuleMember -Function Show-ProjectItemStaged
