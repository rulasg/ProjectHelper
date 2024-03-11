

function ConvertToItemDisplay{
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object]$Item,
        [Parameter()][string[]]$Fields
    )

    process{
        $ret = $item | Select-Object -Property $Fields

        return $ret
    }
}

function FilterItems{
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSCustomObject]$Item,
        [Parameter()][string]$Filter
    )
    begin{
    }
    process{

        # Matches any attribute
        $toReturn = (Test-IsLikeAny -Item $Item -Value $Filter)

        if($toReturn)
        {
            return $Item
        }
    }
}

function Test-IsLike{
    param(
        [Parameter(Mandatory)] [object]$Item,
        [Parameter(Mandatory)] [string]$Attribute,
        [Parameter()][string]$Value
    )

    $ret = $item.$Attribute -Like $Value
    
    return $ret
}

function Test-IsLikeAny{
    param(
        [Parameter(Mandatory)] [object]$Item,
        [Parameter()][string]$Value
    )
    foreach($key in $item.Keys){
        if($item.$key -Like "*$Value*"){
            return $true
        }
    }

    return $false

}