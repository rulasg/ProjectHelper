Set-MyinvokeCommandAlias -Alias ShowInEditor -Command '"{content}" | code -w - '

function Show-ProjectItem{
    [CmdletBinding()]
    [Alias("shpi")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][array[]]$FieldsToShow,
        [Parameter()][switch]$AllComments,
        [Parameter()][switch]$OpenInEditor
    )

    begin{

        $Owner,$ProjectNumber = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber

        if($OpenInEditor){
            Start-WriteBuffer
        }
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
        $item.number | write -Color Cyan -PreFix "# "
        addSpace
        $item.Title | write -Color Yellow -BetweenQuotes
        
        addJumpLine
        
        # URL
        $item.url | write -Color White

        addJumpLine
        
        # Fields by line
        if($FieldsToShow){
            addJumpLine

            foreach($line in $FieldsToShow){
                ShowAttribLine -AttributesToShow $line -Item $item
            }
        }

        addJumpLine
        
        # Body
        "Body" | writeHeader
        $item.Body | write -Color Gray

        # Comments
        if($AllComments){
            # All comments
            $count = 0
            $orderFirst = $item.commentsTotalCount - $item.comments.Count

            foreach($c in $item.comments){
                $count++
                $order = $orderFirst + $count

                writeComment -Comment $c -order $order -item $item
            }
        } else {
            # LastCommment
            if($item.commentLast){
                writeComment -Comment $item.commentLast -order $item.commentsTotalCount -item $item
            }
        }

        # Id at the end
        writeHeader1
        $item.id | write -Color DarkGray ; addJumpLine
    }

    end{
        if($OpenInEditor){
            Stop-WriteBuffer | Open-InEditor
        }
    }
} Export-ModuleMember -Function Show-ProjectItem -Alias("shpi")

function Open-InEditor{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][string]$Content
    )

    process {
        $params = @{
            content = $Content | ConvertTo-InvokeParameterString
        }

        Invoke-MyCommand -Command ShowInEditor -Parameters $params
    }
} Export-ModuleMember -Function Open-InEditor

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

function writeHeader1{
    # [Alias("writeHeader")]
    param(
        [Parameter(ValueFromPipeline, Position=0)][string]$Text
    )

    addJumpLine ;
    if(-not [string]::IsNullOrWhiteSpace($Text)){
        $Text | write Cyan
    }
    addJumpLine
    "------------" | write Cyan
    addJumpLine

}

function writeHeader2{
    [Alias("writeHeader")]
    param(
        [Parameter(ValueFromPipeline, Position=0)][string]$Text,
        [Parameter()][string]$Author,
        [Parameter()][string]$UpdatedAt
    )

    $color = "Cyan"
    $subcolor = "DarkGray"

    $Text = [string]::IsNullOrWhiteSpace($Text) ? " " : $Text

    "## $Text" | write $color

    addJumpLine

    write -Color $subcolor -Text ">"

    if(-not [string]::IsNullOrWhiteSpace($Author)){
        addSpace
        $Author | write -Color $subcolor -PreFix "By: "
    }
    if(-not [string]::IsNullOrWhiteSpace($updatedAt)){
        addSpace
        $updatedAt | write -Color $subcolor -PreFix "At: "
    }

    addJumpLine

}

function writeComment1{
    param(
        [object]$Comment,
        [int]$order,
        [object]$item
    )

    process {
        "Processing Comment by $($Comment.author.login)" | Write-Verbose

        $header = "Comment [$order/$($item.commentsTotalCount)]"
        
        if($order -eq $item.commentsTotalCount) {$header += " Last"}

        addJumpLine
        addJumpLine
        $header | write Cyan
        
        addSpace

        # $Comment.author | write -Color DarkGray -PreFix "By: " ; addSpace

        $Comment.author | write -Color DarkGray -PreFix "<" -SuFix ">" ; addSpace
        $Comment.updatedAt | write -Color DarkGray -PreFix "At: "
        addJumpLine
        "------------" | write Cyan

        # addSpace ; addSpace
        
        addJumpLine
        $Comment.body | write -Color Gray
    }
}
function writeComment2{
    [alias("writeComment")]
    param(
        [object]$Comment,
        [int]$order,
        [object]$item
    )

    process {

        $header = "Comment [$order/$($item.commentsTotalCount)]"
        
        if($order -eq $item.commentsTotalCount) {$header += " Last"}

        addJumpLine -message "Start Comment"
        
        writeHeader $header -Author $Comment.author -UpdatedAt $Comment.updatedAt
        
        addJumpLine -message "Header Done"
        
        $Comment.body | write -Color Gray

    }
}

function write{
    param(
        [Parameter(Position = 1)][string]$color,
        [Parameter(Position = 2,ValueFromPipeline)][string]$text,
        [Parameter()][switch]$BetweenQuotes,
        [Parameter()][string]$PreFix,
        [Parameter()][string]$SuFix,
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

        if($SuFix){
            $text = $text + $SuFix
        }
        

        $text | writetoconsole -Color:$color -NoNewLine

    }
}

$DEBUG_SECTION_SHOWPROJECTITEM = "showprojectitem"
function addJumpLine($message){
    $text = (Test-MyDebug -section $DEBUG_SECTION_SHOWPROJECTITEM) ? "[$message⏎]" : ""
    $text | writetoconsole -Color Blue
}
function addSpace{
    $text = (Test-MyDebug -section $DEBUG_SECTION_SHOWPROJECTITEM) ? "[●]" : " "
    $text | writetoconsole -Color Green -NoNewLine
}

function writetoconsole{
    param(
        [Parameter(ValueFromPipeline)][string]$Color,
        [Parameter(ValueFromPipeline, Position = 0)][string]$Message,
        [Parameter()][switch]$NoNewLine
    )
    $Message | Write-ToConsole -Color $Color -NoNewLine:$NoNewLine
    $Message | Write-ToBuffer -NoNewLine:$NoNewLine
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
        $DefaultValue = $_.DefaultValue ?? "[$name]"
        $HideIfEmpty = $_.HideIfEmpty

        $value = $item.$name

        if($HideIfEmpty -and [string]::IsNullOrEmpty($value)){
            return
        }

        if(!$isfirst){
            " | " | write Gray
        } else {
            $isfirst = $false
        }

        $value | write $color -PreFix $prefix -BetweenQuotes:$BetweenQuotes -DefaultValue $DefaultValue
    }
    addJumpLine
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