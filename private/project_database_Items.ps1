function Get-Item{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$ItemId
    )

    $item = $Database.items | Where-Object { $_.id -eq $ItemId }

    return $item
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

    # TODO: Test that is a valid field based on field type
    $field = Get-Field $Database $FieldName

    if($null -eq $field){
        throw "Field $FieldName not found"
    }

    if( !(Test-FieldChange $field $Value) ){
        throw "Invalid value [$Value] for field $FieldName"
    }

    $node = $Database.Saved | AddHashLink $ItemId
    $node.$FieldName = [PSCustomObject]@{
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
    $node = $Database | AddHashLink "Saved" | AddHashLink $level1 | AddHashLink $level2 | AddHashLink $level3

    For later to set value to 
    $Database.Saved.$level1.$level2.$level3.FieldName = "value"
    
#>
function AddHashLink{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$parent,
        [Parameter(Position = 0)][string]$Name
    )
    process{
        if(-Not ($parent.Keys -contains $Name)){
            $parent[$Name] = @{}
        }

        return $parent[$Name]
    }
}