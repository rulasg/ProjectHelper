function Use-Order {
    [cmdletbinding()]
    [Alias("uo")]
    param(
        [Parameter(ValueFromPipeline)][array]$List,
        [Parameter(Position = 0)][Alias("o")][int]$Ordinal = -1,
        [Parameter()][Alias("e")][switch]$OpenInEditor,
        [Parameter()][Alias("w")][switch]$OpenInBrowser,
        [Parameter()][Alias("p")][switch]$PassThru,
        [Parameter()][Alias("c")][switch]$ClearScreen,
        [Parameter()][scriptblock]$ShowProjectItemScriptBlock
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

        if($ClearScreen){
            Clear-Host
        }

        # Show list of items
        if ($Ordinal -lt 0) {
            return $finalList | Format-Table -AutoSize
        }

        # Show a particular item
        $itemId = $finalList[$Ordinal].id

        if($null -eq $itemId){
            Write-MyError "Item with ordinal $Ordinal not found."
            return
        }

        #return item
        if($PassThru) {
            $i = Get-ProjectItem -ItemId $itemId
            return [PsCustomObject]$i
        }

        # Get function to show item
        $ShowProjectItemScriptBlock = $ShowProjectItemScriptBlock ?? { param($parameters) Show-ProjectItem @parameters }

        # Show item in console or editor
        $params = @{
            Item = $itemId
            OpenInEditor = $OpenInEditor
            OpenInBrowser = $OpenInBrowser
            ClearScreen = $ClearScreen
        }
        $ShowProjectItemScriptBlock.Invoke($params)
        return

    }
} Export-ModuleMember -Function Use-Order -Alias "uo"