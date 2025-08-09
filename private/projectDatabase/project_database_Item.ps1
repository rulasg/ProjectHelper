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
                $fieldname = $database.Staged.$ItemId.$fieldKey.Field.name
                # Make type conversions to string
                $ret.$fieldname = ConvertFrom-FieldValue -Value $database.Staged.$ItemId.$fieldKey.Value -Field $database.fields.$fieldKey
            }
        }

        #if ret is empty, return null
        if($ret.Count -eq 0){
            return $null
        }

        # Add the item id if not present
        $ret.id = $ret.id ?? $ItemId

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

function Edit-Item{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory,Position = 0)][object]$Database,
        [Parameter(Mandatory,Position = 1)][string]$ItemId,
        [Parameter(Mandatory,Position = 2)][string]$FieldName,
        [Parameter(Position = 3)][string]$Value
    )

    # Find the actual value of the item. Item+Staged
    $item = Get-Item $Database $ItemId

    # Check if item exists in cache and if so if the value is the same as the target value and we avoid update
    if($item){
        if( IsAreEqual -Object1:$item.$FieldName -Object2:$Value){
            "The value is the same, no need to stage it" | Write-Verbose
            return
        }
    } else {
        "Staging - Item [$ItemId] not found in project [$Owner/$ProjectNumber] " | Write-Verbose
    }

    # save the new value
    Save-ItemFieldValue $Database $itemId $FieldName $Value

}

function Edit-ItemWithValues {
    param (
        [Parameter()][object]$Database,
        [Parameter(Mandatory)][string]$ItemId,
        [Parameter(Mandatory)][hashtable]$Values,
        [Parameter()][string]$FieldSlug
    )

    $fields = $Database.fields.Values

    # forech key in data do
    foreach ($key in $Values.Keys) {
        $fieldName = $FieldSlug + $key

        # Check if field exists
        $field = $fields | Where-Object { $_.name -eq $fieldName }
        if ($null -eq $field) {
            "Field $fieldName not found" | Write-MyVerbose
            continue
        }

        # Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]
        Edit-Item -Database $Database -ItemId $ItemId -FieldName $fieldName -Value $Values[$key]
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

    #Transform value if needed. Sample SingleSelect will change form String to option
    $value = ConvertTo-FieldValue $field $Value
    if($null -eq $value){
         "Failed convertig value [$Value] for field $FieldName [$($field.dataType)]" | Write-MyError
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