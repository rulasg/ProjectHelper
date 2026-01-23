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
        if ($Ordinal -gt -1) {
            $itemId = $finallist[$Ordinal].id


            if($OpenInBrowser){
                # Open
                $item = Get-ProjectItem -ItemId $itemId
                Open-Url $($item.url)
            } else {
                if($PassThru) {
                    #return item
                    $i = Get-ProjectItem -ItemId $itemId
                    return [PsCustomObject]$i
                } else {
                    # Show
                    Show-ProjectItem -Item $itemId -OpenInEditor:$OpenInEditor
                }
            }
        }
        else {
            $finalList | Format-Table -AutoSize
        }
    }
} Export-ModuleMember -Function Use-Order -Alias "uo"