
Set-MyinvokeCommandAlias -Alias ShowInEditor -Command '"{content}" | code -w - '

function Show-ProjectItem{
    [CmdletBinding()]
    [Alias("shpi")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][array[]]$FieldsToShow,
        [Parameter()][switch]$OpenInEditor
    )

    begin{

        $Owner,$ProjectNumber = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber

        Start-WriteBuffer
    }

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
        addJumpLine ; "--------- Body ---------" | write Cyan ; addJumpLine
        $item.Body | write -Color Gray

        addJumpLine

        # LastCommment
        if($item.commentLast){
            $l = $item.commentLast
            $c = $item.commentCount.ToString().PadLeft(2, '0')
            addJumpLine ; "--- Last Comment [$c/$c] ---" | write Cyan ; addJumpLine
            $l.author | write -Color DarkGray -PreFix "By: " ; addSpace
            $l.updatedAt | write -Color DarkGray -PreFix "At: "
            addJumpLine

            $item.commentLast.body | write -Color Gray
        }

        # End of item
        addJumpLine ; "------------" | write Cyan ; addJumpLine

        # ID at the end
        $item.id | write -Color DarkGray ; addJumpLine
    }

    end{
        if($OpenInEditor){
            $buffer = Stop-WriteBuffer

            $params = @{
                content = $buffer | ConvertTo-InvokeParameterString
            }

            Invoke-MyCommand -Command ShowInEditor -Parameters $params
        }
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

            if([string]::IsNullOrEmpty($DefaultValue)){
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
        $text | Write-ToBuffer -NoNewLine
    }
}

function addJumpLine{
    Write-ToConsole -Color White
    Write-ToBuffer
}
function addSpace{
    " " | Write-ToConsole -Color Cyan -NoNewline
    " " | Write-ToBuffer -NoNewline
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
        $DefaultValue = $_.DefaultValue ?? "<$name>"

        $value = $item.$name

        if(!$isfirst){
            " | " | write Gray
        } else {
            $isfirst = $false
        }

        $value | write $color -PreFix $prefix -BetweenQuotes:$BetweenQuotes -DefaultValue $DefaultValue
    }
}

function Start-WriteBuffer{
    "Starting Write Buffer" | Write-MyDebug -section "WriteBuffer"
    $script:outputBuffer = ""
}
function Stop-WriteBuffer{
    $buffer  = $script:outputBuffer
    
    $script:outputBuffer = $null
    
    "Stopping Write Buffer [$($buffer.Count)] Lines" | Write-MyDebug -section "WriteBuffer"

    return $buffer
}
function Write-ToBuffer {
    param(
        [Parameter(ValueFromPipeline, Position = 0)][string]$Message,
        [Parameter()][switch]$NoNewLine
    )

    if($null -ne $script:outputBuffer){
        "Writing to buffer" | Write-MyDebug -section "WriteBuffer"
        
        $script:outputBuffer += $Message

        if(-not $NoNewLine){
            $script:outputBuffer += "`n"
        }

    } else {
        "No output buffer defined" | Write-MyDebug -section "WriteBuffer"
    }

}