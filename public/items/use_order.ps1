function Use-Order {
    [cmdletbinding()]
    [Alias("uo")]
    param(
        [Parameter(Position = 0)][int]$Ordinal = -1,
        [Parameter(ValueFromPipeline)][array]$List,
        [Parameter()][switch]$OpenInEditor,
        [Parameter()][Alias("w")][switch]$OpenInBrowser,
        [Parameter()][switch]$PassThru
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

    # Show list of items
        if ($Ordinal -lt 0) {
            return $finalList | Format-Table -AutoSize
        }

        # Show a particular item
        $itemId = $finalList[$Ordinal].id

        #return item
        if($PassThru) {
            $i = Get-ProjectItem -ItemId $itemId
            return [PsCustomObject]$i
        }

        # Show item in console or editor
        Show-ProjectItem -Item $itemId -OpenInEditor:$OpenInEditor -OpenInBrowser:$OpenInBrowser
        return

    }
} Export-ModuleMember -Function Use-Order -Alias "uo"