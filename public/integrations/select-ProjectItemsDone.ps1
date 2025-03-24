filter Select-ProjectItemsNotDone {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$Items
    )

    process {
        $ret = New-Object System.Collections.Hashtable
        foreach($itemKey in $Items.Keys){
            if($Items[$itemKey].Status -ne "Done"){
                $ret.$itemKey = $Items[$itemKey]
            }
        }
        return $ret
    }
} 
