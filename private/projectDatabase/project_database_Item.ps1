function Get-Item{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$ItemId
    )

    process {

        $item = $Database.items.$ItemId | Copy-MyHashTable

        $ret = $item ?? $(New-HashTable)

        # Check if is staged
        if($database.Staged.$ItemId){


            # Update ret with all staged fields values
            foreach($fieldKey in $database.Staged.$ItemId.keys){

                $value = $database.Staged.$ItemId.$fieldKey.Value

                if($fieldKey -eq "AddComment"){
                    Set-LastComment -Database $database -Item $ret -comment $value
                    continue
                }

                # Get fieldname
                $fieldname = $database.Staged.$ItemId.$fieldKey.Field.name
                $ret.$fieldname = $database.Staged.$ItemId.$fieldKey.Value
            }
        }

        #if ret is empty, return null
        if($ret.Count -eq 0){
            return $null
        }

        # Add the item id if not present
        # This will happen if we have edited items
        # not downloading the item from server
        $ret.id = $ret.id ?? $ItemId

        return $ret
    }
}

function Set-LastComment{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][hashtable]$Item,
        [Parameter()][string]$comment
    )

    $commentobj = @{
        body = $comment
    }

    # init comments array if needed
    if($null -eq $Item.comments){
        $Item.comments = @()
    }

    # Check if it has just one
    if($Item.comments -is [hashtable]){
        $Item.comments = @($Item.comments) + $commentobj
    } else {
        # TODO: RESEARCH: Why we get error: Method invocation failed because [System.Management.Automation.PSObject] does not contain a method named 'op_Addition'.
        # https://github.com/rulasg/ProjectHelper/issues/233
        try {
            # just added @ so maybe we have fixed the issue
            $Item.comments += @($commentobj)
        }
        catch {
            # Check why throw when we have initiated $item.Comments as @() before.
            Wait-Debugger
        }
    }

    # Update commentLast field
    $Item.commentLast = $commentobj
}

function Find-Item {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$FieldName,
        [Parameter(Position = 2)][string]$Value
    )

    process {

        $found = @()
        foreach($item in $Database.items.Values){
            $item = Get-Item -Database $Database -ItemId $item.id

            if($item.$FieldName -eq $Value){
                $found += $item
            }

        }
        return $found
    }
}

function Get-ItemByUrl{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$Url
    )

    process{

        # Do not use find to improve performance
        # $item = Find-Item -Database $Database -FieldName "urlContent" -Value $Url

        $item = $Database.items.Values | where-Object {$_."urlContent" -eq $Url}

        # Return item with all the fields including staged values
        $ret = Get-Item -Database $db -ItemId $item.id

        return $ret
    }
}

function Test-Item{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$Url
    )

    process{
        $item = Get-ItemByUrl -Database $Database -Url $Url

        return $item.Count -ne 0
    }
}

function Set-Item{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][PSCustomObject]$Item
    )

    if(-not $database){
        $db = New-HashTable
    }
    
    # Add Sanity check for item
    # Ensure that we are adding an item to the proper project database
    Wait-OnItemNotOnDatabase $db $Item

    $items = $db | AddHashLink items

    $items.$($Item.id) = $Item

}

function Remove-Item{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$ItemId
    )

    process{
        Wait-OnItemIdNotOnDatabase $Database $ItemId

        $Database.items.Remove($ItemId) | Out-Null
    }

}

function Set-ItemValue{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value
    )

    Wait-OnItemIdNotOnDatabase $Database $ItemId

    $db = $Database

    $item = $db | AddHashLink items | AddHashLink $ItemId

    # Special case for comments
    if($FieldName -eq "AddComment"){
        Set-LastComment -Database $db -Item $item -comment $Value
    }

    # TODO: MAybe this is wrong and we should not run last line when $FieldName is AddComment.
    $item.$FieldName = $Value
}

function Get-ItemStaged{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$ItemId
    )

    process {
        
        Wait-OnItemIdNotOnDatabase $Database $ItemId

        $staged = $db.Staged.$itemId

        if($null -eq $staged){
            return
        }

        $ret = New-Object System.Collections.Hashtable

        # Fields
        foreach($Field in $staged.Values){
            $ret.$($Field.Field.name) = $($Field.Value)
        }

        return $ret

    }
}

function Remove-ItemStaged{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][object]$Database,
        [Parameter(Mandatory,Position = 1)][string]$ItemId
    )

    Wait-OnItemIdNotOnDatabase $Database $ItemId

    $db = $Database

    # remove item
    if($db.Staged.$ItemId) {
        "Removing staged item [$ItemId] in project [$($db.ProjectId)]" | Write-MyDebug
        $db.Staged.Remove($ItemId)
    } else {
        "Item [$ItemId] not staged in project [$($db.ProjectId)]" | Write-MyWarning
    }
    return
}

function Remove-ItemValueStaged{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][object]$Database,
        [Parameter(Mandatory,Position = 1)][string]$ItemId,
        [Parameter(Mandatory,Position = 2)][string]$FieldId
    )

    Wait-OnItemIdNotOnDatabase $Database $ItemId

    $db = $Database

    # remove field from item

    if ($db.Staged.$ItemId.$FieldId) {
        # Remove value
        "Removing staged field [$FieldId] for item [$ItemId] in project [$($db.ProjectId)]" | Write-MyDebug
        $db.Staged.$ItemId.Remove($FieldId)

        # If no more fields in item remove item
        if ($db.Staged.$ItemId.Count -eq 0) { $db.Staged.Remove($ItemId)}

    } else {
        "Field [$FieldId] not staged for item [$ItemId] in project [$($db.ProjectId)]" | Write-MyWarning
    }
}

<#
.SYNOPSIS
    Stage a change to the database
#>
function Save-ItemFieldValue{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value
    )

    Wait-OnItemIdNotOnDatabase $Database $ItemId

    "Staging item [$ItemId] with field [$FieldName] and value [$Value] in Project [$($Database.ProjectId)]" | Write-MyHost

    $field = Get-Field $Database $FieldName

    if($null -eq $field){
        throw "Field $FieldName not found"
    }
    $fieldId = $field.id

    if( !(Test-FieldValue $field $Value) ){
        throw "Failed testing value [$Value] for field $FieldName [$($field.dataType)]"
    }

    # #Transform value if needed. Sample SingleSelect will change form String to option
    # $value = ConvertTo-FieldValue $field $Value
    # if($null -eq $value){
    #      "Failed convertig value [$Value] for field $FieldName [$($field.dataType)]" | Write-MyError
    #      return
    # }

    $node = $Database | AddHashLink Staged | AddHashLink $ItemId
    $node.$fieldId = [PSCustomObject]@{
        Value = $Value
        Field = $field
    }
}

<#
.SYNOPSIS
    Creates a new hash key if it does not exists
.DESCRIPTION
    This allows a convenient way of creating a chain of hash tables as in a tree of data
.EXAMPLE
    The following sampel will create if not exist the path of the value in a tree of hash tables
    $node = $Database | AddHashLink "Staged" | AddHashLink $level1 | AddHashLink $level2 | AddHashLink $level3

    For later to set value to
    $Database.Staged.$level1.$level2.$level3.FieldName = "value"

#>
function AddHashLink{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$parent,
        [Parameter(Position = 0)][string]$Name
    )
    process{

        # element not present or $null
        if ($null -eq $parent.$Name){
            $parent[$Name] = New-HashTable
        }

        #element present but not a hash table
        if(-Not ($parent[$Name] -is [hashtable])){

            if($parent[$Name].Keys.Count -eq 0){
                # empty element, convert to hash table
                $parent[$Name] = New-HashTable
            }
            else{
                throw "Element $Name is not a hash table"
            }
        }

        return $parent[$Name]
    }
}

function Copy-MyHashTable{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][object]$Object
    )

    process{

        if($null -eq $Object){
            return $null
        }

        if(-not( $object -is [Hashtable])){
            throw "Object is not a hashtable"
        }

        $ret = $Object | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10 -AsHashtable

        return $ret
    }
}

function Copy-MyStringArray{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(ValueFromPipeline,Position = 0)][string[]]$Array
    )

    process{

        if($null -eq $Array){
            return $null
        }

        $ret = @()
        foreach($item in $Array){
            $ret += $item
        }

        return $ret
    }
}

function Wait-OnItemNotOnDatabase($Database,$item){

    if($null -eq $item){
        Write-host "Item is null when working on database [$($Database.title)]" -ForegroundColor Yellow
        # return
    }

    if($Database.ProjectId -ne $Item.projectId){
        write-host "Waiting on database item check for item [$($item.id)] in project [$($Database.title)]" -ForegroundColor Yellow
        Wait-Debugger
    }
}

function Wait-OnItemIdNotOnDatabase($Database,$itemId){

    if(-not $Database.items.$itemId){
        write-host "Waiting on database item id check for item id [$itemId] in project [$($Database.title)]" -ForegroundColor Yellow
        Wait-Debugger
    }
}