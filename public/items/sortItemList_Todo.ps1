function sortItemList_Todo{
    [CmdletBinding()]
    [outputType([array])]
    param(
        [Parameter(Position=0,ValueFromPipeline)][array]$list,
        [Parameter(Mandatory)][string]$DueDateFieldName
    )

    begin {
        $allItems = @()
    }

    process {
        
        $allItems += $list
        
    }
    
    end {

        $properties = @(
            @{ Expression = "due"                            ; Descending = $true  } # Sort first due issues
            @{ Expression = {$null -eq $_.$DueDateFieldName} ; Descending = $true  } # Group by having DueDate value first
            @{ Expression = $DueDateFieldName                ; Descending = $false } # Sort by DueDate field value
            @{ Expression = 'Status'                         ; Descending = $false } # Sort by status
            @{ Expression = { $_.updatedAt.ToString("yyyy-MM-dd") } ; Descending = $false } # Sort by updatedAt (newest first)
            #title
            @{ Expression = 'Title'                          ; Descending = $false } # Sort by title
        )

        "[sortItemList_Todo] Sorting by:" | Write-MyDebug -Section "sortItemList" -Object $properties -objectDepth 1
        
        $ret = $allItems | Sort-Object $properties

        return $ret
    }
} Export-ModuleMember -Function 'sortItemList_Todo'