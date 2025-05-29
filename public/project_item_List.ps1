

function Get-ProjectItemList{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()][switch]$ExcludeDone,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    try {
            $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force
        
            # Check if $db is null
            if($null -eq $db){
                "Project not found. Check owner and projectnumber" | Write-MyError
                return $null
            }

            # Create a hashtable with ItemId as the key
            $ret = New-HashTable
            foreach ($key in $db.items.Keys) {

                $item = Get-ProjectItem -ItemId $key -Owner $Owner -ProjectNumber $ProjectNumber

                if($ExcludeDone -and (Test-ItemIsDone $item)){
                    continue
                }

                if ($null -ne $item) {
                    $ret[$key] = $item
                }
            }

            return $ret
    }  catch {
        "Can not get item list with Force [$Force]; $_" | Write-MyError
    }

} Export-ModuleMember -Function Get-ProjectItemList

function Test-ItemIsDone($Item){

    $ret = $Item.Status -eq "Done" 

    return $ret
}

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

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # return if #db is null
    if($null -eq $items){ return $null}
    
    $ret = $items.Values | Where-Object { $_.Title -like "*$Title*" }
    
    return $ret

} Export-ModuleMember -Function Search-ProjectItemByTitle

function Search-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$filter,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string[]]$Fields,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $Fields = Get-EnvironmentDisplayFields -Fields $Fields

    $itemList = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    if($null -eq $itemList){ return $null}

    $itemListValues = $itemList.Values | FilterItems -Filter $filter

    $items = $itemListValues | ConvertToItemDisplay -Fields $Fields

    Write-MyHost
    "Filter: $filter" | Write-MyHost
    Write-MyHost

    return $items

} Export-ModuleMember -Function Search-ProjectItem

# TODO !! - Figure a way to show table always