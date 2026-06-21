
Register-StubCommand -Name "Stub_ShowProjectTodo" -Description "Show the Project Todo list"

function Show-BaseProjectTodo{
    [cmdletbinding()]
    param(
        # owner and project number 
        [Parameter()][Alias("O")][string]$Owner,
        [Parameter()][Alias("P")][string]$ProjectNumber,
        
        [Parameter()][Alias("t")][string]$Title,
        
        [Parameter()][Alias("pt")][switch]$Passthru,
        [Parameter()][Alias("f")][switch]$Force,
        [Parameter()][Alias("c")][switch]$ClearScreen,
        
        [Parameter()][Alias("n")][Int]$MaxNumber = 30,
        [Parameter()][Alias("a")][switch]$All,
        
        # Ordinal
        [Parameter(Position=0)][int]$Ordinal = -1,

        # Status
        [parameter()][Alias("s")][string[]]$Status,
        
        # Attributes
        [parameter()][Alias("Att")][string[]]$Attributes
    )

    $owner,$ProjectNumber = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $MaxNumber = $ALL ? 0 : $MaxNumber

    if($Attributes){
        $attribsToSelect = @("id","Title")
        $attribsToSelect += $Attributes
    } else {
        $attribsToSelect = @("id","Title","Status","Comment")
    }

    $params = @{
        Owner = $owner
        ProjectNumber = $ProjectNumber
        Title = $Title
        Force = $Force
        Status = $Status
    }

    $list = Get-ProjectItemTodo @params

    # Select fields to display - This list has to come from $list
    $selected = $list | Select-Object -Property $attribsToSelect

    # Use Order
    $params2 = @{
        Owner = $owner
        ProjectNumber = $ProjectNumber
        Ordinal = $Ordinal
        OpenInBrowser = $OpenInBrowser
        PassThru = $Passthru
        ClearScreen = $ClearScreen
    }

    # show all items together
    $selected = $MaxNumber -gt 0 ? $($selected | Select-Object -First $MaxNumber) : $selected
    Use-Order @params2 -List $selected

} Export-ModuleMember -Function Show-BaseProjectTodo

function Get-ProjectItemTodo{
    [cmdletbinding()]
    [Alias("gpit")]
    param(
        # owner and project number 
        [Parameter()][Alias("O")][string]$Owner,
        [Parameter()][Alias("P")][string]$ProjectNumber,
        
        [Parameter()][Alias("t")][string]$Title,
        
        [Parameter()][Alias("f")][switch]$Force,
        
        # Status
        [parameter()][Alias("s")][string[]]$Status
    )

    $owner,$ProjectNumber = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    # Get config values
    if([string]::IsNullOrEmpty($Status)){
        $Status = Get-ProjectConfigValue -FieldName [ConfigKey]::ReadyStatus -Owner $owner -ProjectNumber $ProjectNumber -DefaultValue $DEFAULT_CONFIG_VALUES.$([ConfigKey]::ReadyStatus.ToString())
    }
    $dueDateFieldName = Get-ProjectConfigValue -FieldName [ConfigKey]::DueDateFieldName -Owner $owner -ProjectNumber $ProjectNumber -DefaultValue $DEFAULT_CONFIG_VALUES.$([ConfigKey]::DueDateFieldName.ToString())

    $list = @()
    
    # Search items by Status
    $allList = Get-ProjectItems -Owner $owner -ProjectNumber $ProjectNumber -Force:$Force
    
    # Get items by Status
    $Status | ForEach-Object{ $st = $_ ; $list += $allList | Where-Object{ $_.Status -eq $st } }

    # Add dued
    $list = $allList | Where-Object{ -not [string]::IsNullOrEmpty($_.$dueDateFieldName) } | addToListIfNotContained -List $list

    # Sort
    # To sort properly $list has to contains the required fields for sorting
    $sorted = sortItemList_Todo -list $list -DueDateFieldName $dueDateFieldName

    return $sorted

} Export-ModuleMember -Function Get-ProjectItemTodo -Alias("gpit")


function addToListIfNotContained{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][PSCustomObject]$Item,
        [Parameter(Mandatory)][object]$List
    )
    begin{ 
        $ids = $list.id
    }
    process{ 
        if($ids -notcontains $Item.id ){ 
            $List += $Item 
        }
    }
    end{
        # sanity check
        $count = $list.Count ; $uniqueCount = ( $list | Select-Object -Property id -Unique ).Count
        if( $count -ne $uniqueCount ){ throw "List contains duplicate items. Count: $count, Unique Count: $uniqueCount" }

        #return the list
        return $List
    }
}

