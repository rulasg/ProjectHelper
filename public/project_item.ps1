Set-MyInvokeCommandAlias -Alias AddItemToProject -Command 'Invoke-AddItemToProject -ProjectId {projectid} -ContentId {contentid}'
Set-MyInvokeCommandAlias -Alias RemoveItemFromProject -Command 'Invoke-RemoveItemFromProject -ProjectId {projectid} -ItemId {itemid}'

<#
.SYNOPSIS
    Get a project item.
.DESCRIPTION
    Fields will show th emerge between Project and Staged Item fields values
.EXAMPLE
    Get-ProjectItem -Owner "someOwner" -ProjectNumber 164 -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc
    #>
function Get-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 2)][string]$ItemId,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

    $item = Get-Item $db $ItemId

    return $item
} Export-ModuleMember -Function Get-ProjectItem

<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function Edit-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value,
        [Parameter()][switch]$Force
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get database
    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

    # update the database with the new value
    Edit-Item $db $ItemId $FieldName $Value

    # Commit changes to the database
    Save-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Database $db

} Export-ModuleMember -Function Edit-ProjectItem

function Add-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string]$Url,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    process{

        ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

        # Get project id
        $projectId = Get-ProjectId -Owner $Owner -ProjectNumber $ProjectNumber
        if(-not $projectId){
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return $null
        }

        # Get item id
        $contentId = Get-ContentIdFromUrl -Url $Url
        if(-not $contentId){
            "Content ID not found for URL [$Url]" | Write-MyError
            return $null
        }

        # Add item to project
        $response = Invoke-MyCommand -Command AddItemToProject -Parameters @{ projectid = $projectId ; contentid = $contentId }

        # check if the response is null
        if($response.errors){
            "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
            return $null
        }

        if($response.data.addProjectV2ItemById.item.id)
        {
            $ret = $response.data.addProjectV2ItemById.item.id
            $global:ItemId = $ret

            return $ret
            
        } else {
            "Item not added to project" | Write-MyError
            return $null
        }
    }

} Export-ModuleMember -Function Add-ProjectItem

function Remove-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 0)][string]$ItemId
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project id
    $projectId = Get-ProjectId -Owner $Owner -ProjectNumber $ProjectNumber
    if(-not $projectId){
        "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
        return $null
    }

    # Remove item from project
    $response = Invoke-MyCommand -Command RemoveItemFromProject -Parameters @{ projectid = $projectId ; itemid = $ItemId }

    # check if the response is null
    if($response.errors){
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if($response.data.deleteProjectV2Item.deletedItemId -ne $ItemId){
        "Some issue removing [$ItemId]from project" | Write-MyError
        return $null
    }

    return $response.data.deleteProjectV2Item.deletedItemId

} Export-ModuleMember -Function Remove-ProjectItem

function IsAreEqual{
    param(
        [object]$Object1,
        [object]$Object2
    )

    $Object1 = [string]::IsNullOrEmpty($Object1) ? $null : $Object1
    $Object2 = [string]::IsNullOrEmpty($Object2) ? $null : $Object2

    # Check if the objects are equal
    $ret = $Object1 -eq $Object2

    return $ret
}