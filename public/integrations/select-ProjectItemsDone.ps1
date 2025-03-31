filter Select-ProjectItemsNotDone {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$Items
    )

    begin{
        $count = 0
        $countNotStatus = 0
    }
    process {
        $ret = New-Object System.Collections.Hashtable
        foreach($itemKey in $Items.Keys){

            if($Items[$itemKey].Status -eq "Done"){
                $count++
            } else {
                $ret.$itemKey = $Items[$itemKey]
            }
        } 
        return $ret
    }
    end{
        "Filtered items that are done : $count" | Write-MyVerbose
    }
} 
