function Use-Order {
    [cmdletbinding()]
    [Alias("uo")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(ValueFromPipeline)][array]$List,
        [Parameter()][string]$Title,
        [Parameter()][hashtable]$FilterFields,
        [Parameter(Position = 0)][Alias("o")][int]$Ordinal = -1,
        [Parameter()][Alias("e")][switch]$OpenInEditor,
        [Parameter()][Alias("w")][switch]$OpenInBrowser,
        [Parameter()][Alias("p")][switch]$PassThru,
        [Parameter()][Alias("c")][switch]$ClearScreen,
        [Parameter()][switch]$NotClearScreenOnItemShow,
        [Parameter()][Int]$MaxNumber

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
            Clear-MyHost
        }

        # Show list of items
        if ($Ordinal -lt 0) {
            #return items

            # Filter by Title
            if(-not [string]::IsNullOrEmpty($Title)) {
                $finalList = $finalList | Where-Object { $_.Title -like "*$Title*" }
            }

            # Filter by fields if provided
            if($FilterFields) {
                foreach($key in $FilterFields.Keys) {
                    $value = $FilterFields[$key]
                    $finalList = $finalList | Where-Object { $_.$key -like "*$value*" }
                }
            }

            # Filter by MaxNumber if specified
            if($MaxNumber -gt 0) {
                $finalList = $finalList | Select-Object -First $MaxNumber
            }

            if($PassThru) {
                return [PsCustomObject]$finalList
            } else {
                $finalList | Format-Table -Property * -AutoSize
                return
            }
        }

        # Show a particular item
        $itemId = $finalList[$Ordinal].id

        if($null -eq $itemId){
            Write-MyError "Item with ordinal $Ordinal not found."
            return
        }

        # To work on the item we need Owner and ProjectNumber from the environment. If not set, we cannot continue.
        if( -Not (Test-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber) ){
            throw "ProjectEnvironment is required. Run Set-ProjectHelperEnvironment"
        }

        #Return or show
        if($PassThru) {
            $i = Get-BaseProjectItem -ItemId $itemId
            return [PsCustomObject]$i
        } else {
            # Show item in console or editor
            $params = @{
                Owner = $Owner
                ProjectNumber = $ProjectNumber
                Item = $itemId
                OpenInEditor = $OpenInEditor
                OpenInBrowser = $OpenInBrowser
                NotClearScreen = $NotClearScreenOnItemShow
            }
            Stub_ShowProjectItem @params
        }
    }
} Export-ModuleMember -Function Use-Order -Alias "uo"