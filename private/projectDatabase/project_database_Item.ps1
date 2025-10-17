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
                # Make type conversions to string
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

    # Update commentLast field
    $Item.commentLast = $commentobj
    $Item.comments += $commentobj
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

function Test-Item{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$Url
    )

    process{
        $item = Find-Item -Database $Database -FieldName "urlContent" -Value $Url

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

    $db = $Database

    $item = $db | AddHashLink items | AddHashLink $ItemId

    # Special case for comments
    if($FieldName -eq "AddComment"){
        Set-LastComment -Database $db -Item $item -comment $Value
    }

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
        [Parameter(Position = 0)][object]$Database,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldId
    )

    $db = $Database

    if ($db.Staged.$ItemId.$FieldId) {
        # Remove value
        $db.Staged.$ItemId.Remove($FieldId)
        
        # If no more fields in item remove item
        if ($db.Staged.$ItemId.Count -eq 0) { $db.Staged.Remove($ItemId)}

    } else {
        # remove item
        $db.Staged.Remove($ItemId)
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