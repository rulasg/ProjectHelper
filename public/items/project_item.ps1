Set-MyInvokeCommandAlias -Alias AddItemToProject -Command 'Invoke-AddItemToProject -ProjectId {projectid} -ContentId {contentid}'
Set-MyInvokeCommandAlias -Alias RemoveItemFromProject -Command 'Invoke-RemoveItemFromProject -ProjectId {projectid} -ItemId {itemid}'
Set-MyInvokeCommandAlias -Alias GetItem -Command 'Invoke-GetItem -ItemId {itemid}'

<#
.SYNOPSIS
    Get a project item.
.DESCRIPTION
    Fields will show th emerge between Project and Staged Item fields values
.EXAMPLE
    Get-ProjectItem -Owner "someOwner" -ProjectNumber 164 -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc
#>
function Get-ProjectItem {
    [CmdletBinding()]
    [Alias ("gpi")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems

        if(! $db){ "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError; return $null}

        # Dirty flag
        $dirty = $false
    }

    process {
        $item, $dirty = Resolve-ProjectItem -Database $db -ItemId $ItemId -Force:$Force

        return $item
    }
    
    end {
        if ($dirty) {
            "Saving dirty database" | Write-Verbose
            Save-ProjectDatabaseSafe -Database $db
        }
    }

} Export-ModuleMember -Function Get-ProjectItem -Alias "gpi"

function Test-ProjectItem {
    [CmdletBinding()]
    [Alias ("tpi")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Url,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    }

    process {

        $ret = Test-Item -Database $db -Url $Url
        
        return $ret
    }

} Export-ModuleMember -Function Test-ProjectItem -Alias "tpi"

function Search-ProjectItem {
    [CmdletBinding()]
    [Alias ("spi")]
    param(
        [Parameter(Position = 0)] [string[]]$Filter,
        [Parameter(Position = 1)][string[]]$Attributes,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        [Parameter()][string]$FieldName,
        [Parameter()][switch]$AnyField,
        [Parameter()][switch]$Exact

    )

    if([string]::IsNullOrWhiteSpace($Attributes)){
        $Attributes = @("id", "Title")
    }

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if ($null -eq $items) { return $null }

    if($null -eq $Filter -or $Filter.Count -eq 0){
        $found = $items.Values
    } else {

        if($AnyField){
            if($Exact){
                # Exact match in any field
                $found = $items.Values | Where-Object { Test-WhereExactAnyField -Item $_ -Values $Filter -OR }
            } else {
                # Like match in any field
                $found = $items.Values | Where-Object { Test-WhereLikeAnyField -Item $_ -Values $Filter }
            }
            $found = $items.Values | Where-Object { Test-WhereLikeAnyField -Item $_ -Values $Filter }
        } else {
            # Default to "Title as the single field to search"
            $FieldName = [string]::IsNullOrWhiteSpace($FieldName) ? "Title" : $FieldName
            
            if($Exact){
                # Pick just the first value a in Exact fielname there is only one match Fieldname value
                $found = $items.Values | Where-Object { Test-WhereExactField -Item $_ -Fieldname $FieldName -Value $Filter[0] }
            } else {
                $found = $items.Values | Where-Object { Test-WhereLikeField -Item $_ -Fieldname $FieldName -Values $Filter }
            }
        }
    }

    if($PassThru){
        $ret = $found
    } else {
        $ret = $found | Format-ProjectItem -Attributes $Attributes
    }

    # If Title is in attributes, sort by title
    if($Attributes -contains "Title") {
        $ret = $ret | Sort-Object -Property Title
    }

    return $ret

} Export-ModuleMember -Function Search-ProjectItem -Alias "spi"

function Format-ProjectItem{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][object]$Item,
        [Parameter(Position = 1)][string[]]$Attributes
    )

    begin {
        if([string]::IsNullOrWhiteSpace($Attributes)){
            $Attributes = @("id", "Title")
        }
    }

    process{

        $ret = [pscustomobject]::new()

        foreach($a in $Attributes){
            if( ! $Item.$a){
                continue
            }

            $ret | Add-Member -MemberType NoteProperty -Name $a -Value $Item.$a -force
        }

        return $ret
    }
} Export-ModuleMember -Function Format-ProjectItem

function Get-ProjectItems {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }

    $items = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -ExcludeDone:$(-not $IncludeDone)

    # return if #items is null
    if ($null -eq $items) { return $null }

    $ret = @($items.Values | ForEach-Object { 
            [PSCustomObject]$_
        } )

    return $ret

} Export-ModuleMember -Function Get-ProjectItems

function Open-ProjectItem {
    [CmdletBinding()]
    [Alias ("opi")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [string]$Id,
        [Parameter()][switch]$InProject
    )

    begin {

        
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
            throw "Owner and ProjectNumber are required on Open-ProjectItem"
        }
        
        "Project set to [$owner/$ProjectNumber]" | Write-Verbose

    }

    process {

        $itemId = $Id

        "Opening item [$ItemId] in project [$Owner/$ProjectNumber]" | Write-Verbose
   
        $item = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $ItemId
        if (-not $item) {
            throw "Item not found for Owner [$Owner], ProjectNumber [$ProjectNumber] and ItemId [$ItemId]"
        }

        if($InProject){
            $url = $item.urlPanel
        } else {
            # fall back to url if urlcontent is empty
            $url = $item.urlContent ?? $item.url
        }
        
        if ([string]::IsNullOrWhiteSpace($url)) {
            # We should never reach this point as all items has a urlpanel set in Convert-NodeItemToHash
            "No URL found for Item [$ItemId] type [ $($item.type) ]" | Write-Error
            return 
        }

        Open-Url -Url $url
    }
} Export-ModuleMember -Function Open-ProjectItem -Alias "opi"

<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function Edit-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value,
        [Parameter()][switch]$Force
    )

    process{

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
        
        # Force cache update
        # Full sync if force. Skip items if not force
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)
        
        # Find the actual value of the item. Item+Staged
        # Ignore $dirty as we are changing the db we will always save
        ($item, $dirty) = Resolve-ProjectItem -Database $db -ItemId $ItemId
        
        # if the item is not found
        if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return $null}
        
        # Value transformations
        $valueTransformed = Convertto-ItemTransformedValue -Item $item -Value $Value
        
        # Check if value is the same
        if ( AreEqual -Object1:$item.$FieldName -Object2:$valueTransformed) {
            "The value is the same, no need to stage it" | Write-Verbose
            return
        }
        
        # save the new value
        Save-ItemFieldValue $db $itemId $FieldName $valueTransformed
        
        # Commit changes to the database
        Save-ProjectDatabaseSafe -Database $db
    }

} Export-ModuleMember -Function Edit-ProjectItem

function Reset-ProjectItem {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName
    )

    process{

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
        
        # Force cache update
        # Full sync if force. Skip items if not force
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems:$(-not $Force)

        # Remove staged
        if([string]::IsNullOrWhiteSpace($FieldName)){
            # Remove all staged changes for the item
            Remove-ItemStaged $db $ItemId
        } else {
            #Remove just the field staged change
            $field = Get-Field $db $FieldName
            if([string]::IsNullOrWhiteSpace($field)){
                # Field not found
                throw "Field [$FieldName] not found in project"
            } else {
                "Removing staged field [$FieldId] for item [$ItemId] in project [$($db.ProjectId)]" | Write-MyDebug
                Remove-ItemValueStaged $db $ItemId $field.id
            }
        }

        # Commit changes to the database
        Save-ProjectDatabaseSafe -Database $db
    }

} Export-ModuleMember -Function Reset-ProjectItem

function Add-ProjectItemDirect {
    [CmdletBinding()]
    [alias("Add-ProjectItem", "api")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Url,
        [Parameter()][switch]$NoCache
    )

    begin{
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
    
        # Get project id
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
        $projectId = $db.ProjectId
        if (-not $projectId) {
            "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return $null
        }
    }

    process {

        if(Test-ProjectItem -Url $Url -Owner $Owner -ProjectNumber $ProjectNumber){
            $item = Search-ProjectItem -Filter $Url -FieldName "urlContent" -IncludeDone -Owner $Owner -ProjectNumber $ProjectNumber -PassThru
            return $item.id
        }

        # Get item id
        $contentId = Get-ContentIdFromUrlDirect -Url $Url
        if (-not $contentId) {
            "Content ID not found for URL [$Url]" | Write-MyError
            return $null
        }

        # Add item to project
        $response = Invoke-MyCommand -Command AddItemToProject -Parameters @{ projectid = $projectId ; contentid = $contentId }

        # check if the response is null
        if ($response.errors) {
            "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
            return $null
        }

        $item = $response.data.addProjectV2ItemById.item

        if ($item) {
            $ret = $item.id

            if (! $NoCache) {
                "Adding item [$ret] to cache" | Write-Verbose

                $item = $item | Convert-NodeItemToHash

                Set-Item $db $item

                Save-ProjectDatabaseSafe -Database $db

            }

            return $ret

        }
        else {
            "Item not added to project" | Write-MyError
            return $null
        }
    }

} Export-ModuleMember -Function Add-ProjectItemDirect -Alias "Add-ProjectItem", "api"

function Remove-ProjectItemDirect {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName,ValueFromPipeline, Position = 0)][Alias("Id")][string]$ItemId,
        [Parameter()][switch]$Force
    )

    begin {
        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { "Owner and ProjectNumber are required" | Write-MyError; return $null }
        
        # Get project id
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
        if ($db) {
            $projectId = $db.ProjectId
        }
        else {
            throw "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]"
        }
    }

    process {

        try{
            if (-not $projectId) {
                "Project ID not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
                return $null
            }

            # Remove item from project
            if ($PSCmdlet.ShouldProcess($ItemId, "RRemove from project $Owner/$ProjectNumber")) {
                $response = Invoke-MyCommand -Command RemoveItemFromProject -Parameters @{ projectid = $projectId ; itemid = $ItemId }
            } else {
                # Fake execution return ItemId
                return $ItemId
            }
            
            # check if FAILED
            if ($response.errors -or ($response.data.deleteProjectV2Item.deletedItemId -ne $ItemId)) {
                "Some issue removing [$ItemId] from project" | Write-MyError

                if($Force){
                    "Force flag is set, removing item from cache anyway" | Write-Verbose
                    Remove-Item $db $ItemId
                    Save-ProjectDatabaseSafe -Database $db
                    return $null
                }
            }
            
            $ret = $response.data.deleteProjectV2Item.deletedItemId
        }
        catch {
            "Item [$ItemId] not found in project [$Owner/$ProjectNumber]" | Write-MyWarning
            return
        }
            
        # Remove item from cache
        "Removing item [$ItemId] from cache" | Write-Verbose
        Remove-Item $db $ItemId
        Save-ProjectDatabaseSafe -Database $db

        return $ret
    }

} Export-ModuleMember -Function Remove-ProjectItemDirect

function Get-ProjectItemDirect {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$ItemId
    )

    $response = Invoke-MyCommand -Command GetItem -Parameters @{
        itemid = $ItemId
    }

    # check if the response is null
    if ($response.errors) {
        "[$($response.errors[0].type)] $($response.errors[0].message)" | Write-MyError
        return $null
    }

    if ($response.data.node.id -ne $ItemId) {
        "Item [$ItemId] not found" | Write-MyError
        return $null
    }

    $item = $response.data.node | Convert-NodeItemToHash

    return $item
} Export-ModuleMember -Function Get-ProjectItemDirect



function Test-WhereLikeAnyField {
    param(
        [Parameter(Mandatory, ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory, Position = 0)][string[]]$Values
    )

    process{

        foreach ($key in $item.Keys) {
            if( Test-WhereLikeField -Item $item -Fieldname $key -Values $Values ) {
                return $true
            }
        }
        
        return $false
    }
}

function Test-WhereExactAnyField {
    param(
        [Parameter(Mandatory, ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory, Position = 0)][string]$Value
    )

    process{

        foreach ($key in $item.Keys) {
            if( Test-WhereExactField -Item $item -Fieldname $key -Value $Value ) {
                return $true
            }
        }
        
        return $false
    }
}

function Test-WhereLikeField {
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory)][string]$FieldName,
        [Parameter(Mandatory)][string[]]$Values,
        [Parameter()][switch]$OR
    )

    process {

        $itemValue = $item.$FieldName

        $foundCount = 0
        
        foreach ($v in $Values) {
            if( $itemValue -like "*$v*"){
                $foundCount ++
            }
        }

        return $foundCount -eq $Values.Count
    }
}

function Test-WhereExactField {
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [object]$Item,
        [Parameter(Mandatory)][string]$FieldName,
        [Parameter(Mandatory)][string]$Value,
        [Parameter()][switch]$OR
    )

    process {

        $itemValue = $item.$FieldName

        $ret = $itemValue -eq $Value

        return $ret

    }
}


function AreEqual {
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