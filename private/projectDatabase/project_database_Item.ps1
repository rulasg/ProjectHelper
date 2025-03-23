function Get-Item{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)][object[]]$Database,
        [Parameter(ValueFromPipeline, Position = 1)][string]$ItemId
    )

    process {

        $item = $Database.items.$ItemId
        
        # Check if is staged
        if($database.Staged.$ItemId){
            foreach($field in $database.Staged.$ItemId.keys){
                $fieldname = $database.Staged.$ItemId.$field.Field.name
                $fieldValue =$database.Staged.$ItemId.$field.Value
                $item.$fieldname = $fieldValue
            }
        }
        
        return $item
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

        $item = Get-Item $db $itemId
        $staged = $db.Staged.$itemId

        if($null -eq $staged){
            return
        }

        $changedItem = New-Object System.Collections.Hashtable

        # Heade
        $changedItem.Id = $item.id
        $changedItem.type = $item.type
        $changedItem.Title = $item.Title
        
        # Add RepoNumber as human identifier
        # Url not present for draftitems
        if($item.url){
            $uri = [uri]$item.url
            $num = $uri | Split-Path -leaf
            $repo = $uri | Split-Path -Parent | Split-Path -parent | Split-Path -leaf
            
            $changedItem.RepoNumber = "$repo/$num"
        }
        
        $changedItem.Fields = @()
        
        # Fields
        foreach($Field in $staged.Values){
            $changedItem.Fields += [PSCustomObject]@{
                Name = $Field.Field.name
                Value = $Field.Value
            }
        }

        return [pscustomobject] $changedItem

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

    if( !(Test-FieldChange $field $Value) ){
        throw "Invalid value [$Value] for field $FieldName"
    }

    #Transform value if needed. Sample SingleSelect will change form String to option
    $value = Get-FieldValue $field $Value
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