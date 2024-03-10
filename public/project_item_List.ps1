

function Get-ProjectItemList{
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
    return $db.items

} Export-ModuleMember -Function Get-ProjectItemList

# function Reset-ProjectItemList{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)] [string]$Owner,
#         [Parameter(Position = 1)] [string]$ProjectNumber,
#         [Parameter()][switch]$Force
#     )

#     $saved = Test-ProjectDatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber

#     if($saved -and -Not $Force){
#         "There are unsaved changes, please commit or use -Force" | Write-MyError
#         return
#     }

#     Reset-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

# } Export-ModuleMember -Function Reset-ProjectItemList

function Find-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $items){ return $null }

    $ret =  $items.Values | Where-Object { $_.Title.Trim().ToLower() -eq $($Title.Trim().ToLower()) }

    return $ret

} Export-ModuleMember -Function Find-ProjectItemByTitle

function Search-ProjectItemByTitle{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Position = 2)] [string]$Title,
        [Parameter()][switch]$Force
    )

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $items){ return $null}
    
    $ret = $items.Values | Where-Object { $_.Title -like "*$Title*" }
    
    return $ret

} Export-ModuleMember -Function Search-ProjectItemByTitle

