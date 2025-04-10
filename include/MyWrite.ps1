
$ERROR_COLOR = "Red"
$WARNING_COLOR = "Yellow"
$OUTPUT_COLOR = "DarkCyan"

function Write-MyError{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $ERROR_COLOR
    Write-ToConsole $message -Color $ERROR_COLOR
}

function Write-MyWarning{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $WARNING_COLOR
    Write-ToConsole $message -Color $WARNING_COLOR
}

function Write-MyVerbose{
    param(
        [Parameter(ValueFromPipeline)][string]$Message
    )
    Write-Verbose -Message $message
}

function Write-MyHost{
    param(
        [Parameter(ValueFromPipeline)][string]$Message
    )
    # Write-Host $message -ForegroundColor $OUTPUT_COLOR
    Write-ToConsole $message -Color $OUTPUT_COLOR
}

function Write-ToConsole{
    param(
        [Parameter(ValueFromPipeline)][string]$Color,
        [Parameter(ValueFromPipeline, Position=0)][string]$Message
    )
    Write-Host $message -ForegroundColor $Color
}