function Show-ProjectItem{
    [CmdletBinding()]
    [Alias("shpi")]
    param(
        [Parameter(ValueFromPipeline)][string]$ItemId,
        [Parameter()][array[]]$FieldsToShow
    )

    process {

        $item = Get-ProjectItem -ItemId $ItemId

        if($null -eq $item){
            "Item not found" | Write-MyError
            return $null
        }

        if(-not $FieldsToShow){
            $statusColor = getStatusColor($item.Status)
            $FieldsToShow = @(
                @(@{Name="Status"; Color = $statusColor})
            )
        }
        
        # Before all
        addJumpLine

        # title bar
        # ($item.RepositoryOwner + "/") | write -Color Cyan
        # ($item.RepositoryName) | write -Color Cyan
        $item.number | write -Color Cyan -PreFix "#"
        addSpace
        $item.Title | write -Color Yellow -BetweenQuotes
        
        addJumpLine
        
        # URL
        $item.url | write -Color White

        # Fields by line
        if($FieldsToShow){
            addJumpLine
            foreach($line in $FieldsToShow){
                addJumpLine
                ShowAttribLine -AttributesToShow $line -Item $item
            }
        }

        addJumpLine
        
        # Body
        addJumpLine ; "--- Body ---" | write Cyan ; addJumpLine
        $item.body | write -Color Gray

        # End of item
        addJumpLine ; "------------" | write Cyan ; addJumpLine

        # ID at the end
        $item.id | write -Color DarkGray
    }
} Export-ModuleMember -Function Show-ProjectItem -Alias("shpi")

function getStatusColor{
    param(
        [string]$status
    )

    switch ($status.ToLower()) {
        "Todo" { return "Green" }
        "Done" { return "DarkMagenta" }
        "In Progress" { return "Yellow" }
        default { return "Gray" }
    }
}

function write{
    param(
        [Parameter(Position = 1)][string]$color,
        [Parameter(Position = 2,ValueFromPipeline)][string]$text,
        [Parameter()][switch]$BetweenQuotes,
        [Parameter()][string]$PreFix,
        [Parameter()][string]$DefaultValue

    )
    process{

        if([string]::IsNullOrWhiteSpace($text)){

            if([string]::IsNullOrWhiteSpace($DefaultValue)){
                $DefaultValue = "(empty)"
            }
            $text = $DefaultValue
        }

        if($BetweenQuotes){
            $text = """$text"""
        }

        if($PreFix){
            $text = $PreFix + $text
        }
        

        $text | Write-ToConsole -Color:$color -NoNewLine
    }
}
function addJumpLine{
    Write-ToConsole -Color White
}
function addSpace{
    " " | Write-ToConsole -Color Cyan -NoNewline
}
function ShowAttribLine{
    param(
        [array]$AttributesToShow,
        [object]$item
    )

    $isfirst = $true

    $AttributesToShow | ForEach-Object {
        $name = $_.Name
        $color = $_.Color
        $prefix = $_.Prefix
        $BetweenQuotes = $_.BetweenQuotes
        
        $value = $item.$name

        if(!$isfirst){
            " | " | write Gray
        } else {
            $isfirst = $false
        }

        $value | write $color -PreFix $prefix -BetweenQuotes:$BetweenQuotes -DefaultValue "<$name>"
    }
}