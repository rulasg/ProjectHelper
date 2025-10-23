function Use-Order {
    [cmdletbinding()]
    [Alias("uo")]
    param(
        [Parameter(Position = 0)][int]$Ordinal = -1,
        [Parameter(ValueFromPipeline)][array]$List,
        [Parameter()][switch]$OpenInEditor
    )

    begin {
        $finallist = @()
        $i = 0
    }
    process {
        $newList = @()
        foreach ($item in $List) {
            # Rebuild object so "#" is the first property
            $props = [ordered]@{ '#' = $i }
            foreach($p in $item.PSObject.Properties){
                $props[$p.Name] = $p.Value
            }
            $newList += [pscustomobject]$props
            $i++
        }

        $finalList += $newList
    }

    end {
        if ($Ordinal -gt -1) {
            $itemId = $finallist[$Ordinal].id
            Show-ProjectItem -Item $itemId -OpenInEditor:$OpenInEditor
        }
        else {
            $finalList | Format-Table -AutoSize
        }
    }
} Export-ModuleMember -Function Use-Order -Alias "uo"