function Get-ItemId{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$Title
    )

    $item = $Database.items | Where-Object { $_.title -eq $Title }

    return $item.id
}

function Get-ItemFieldValue{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(Position = 1)][string]$ItemId,
        [Parameter(Position = 2)][string]$FieldName
    )

    $item = $Database.items | Where-Object { $_.id -eq $ItemId }

    return $item.$FieldName
}

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

    $isValidChange = Test-FieldChange $field $Value

    if(-Not $isValidChange){
        throw "Invalid value [$Value] for field $FieldName"
    }

    $node = $Database.Saved | AddHashLink $ItemId
    $node.$FieldName = [PSCustomObject]@{
        Value = $Value
        Field = $field
    }
}

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