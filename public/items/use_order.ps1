function Use-Order {
    [cmdletbinding()]
    [Alias("uo")]
    param(
        [Parameter(Position = 0)][int]$Ordinal = -1,
        [Parameter(ValueFromPipeline)][array]$List
    )

    begin {
        $finallist = @()
    }
    process {

        foreach ($item in $List) {
            if ($null -eq $i) { $i = 0 }
            $item | Add-Member -NotePropertyName "#" -NotePropertyValue $i -Force
            $i++
        }
            
        $finalList += $List
    }

    end {
        if ($Ordinal -gt -1) {
            $itemId = $finallist[$Ordinal].id
            Show-SalesProjectItem -Item $itemId
        }
        else {
            return $finalList
        }
    }
} Export-ModuleMember -Function Use-Order -Alias "uo"