function Get-Item{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$ItemId
    )

    process {

        $item = $Database.items.$ItemId

        $ret = $item | Copy-MyHashTable

        # Check if is staged
        if($database.Staged.$ItemId){
            foreach($field in $database.Staged.$ItemId.keys){
                $fieldname = $database.Staged.$ItemId.$field.Field.name
                $fieldValue =$database.Staged.$ItemId.$field.Value
                $ret.$fieldname = $fieldValue
            }
        }
        
        return $ret
    }
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
    # TODO !! : Test that is a valid field based on field type
    
    $field = Get-Field $Database $FieldName
    
    if($null -eq $field){
        throw "Field $FieldName not found"
    }
    $fieldId = $field.id

    if( !(Test-FieldValue $field $Value) ){
        throw "Invalid value [$Value] for field $FieldName"
    }

    #Transform value if needed. Sample SingleSelect will change form String to option
    $value = ConvertTo-FieldValue $field $Value
    if($null -eq $value){
         "Invalid value [$Value] for field $FieldName [$($field.dataType)]" | Write-MyError
         return
    }

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
            $parent[$Name] = New-Object System.Collections.Hashtable
        }
        
        #element present but not a hash table
        if(-Not ($parent[$Name] -is [hashtable])){
            throw "Element $Name is not a hash table"
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
        
        $ret = $Object | ConvertTo-Json | ConvertFrom-Json -AsHashtable

        return $ret
    }
}