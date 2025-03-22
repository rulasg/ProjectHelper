
$ERROR_COLOR = "Red"
$WARNING_COLOR = "Yellow"
$OUTPUT_COLOR = "DarkCyan"

function Write-MyError{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host "Error: $message" -ForegroundColor $ERROR_COLOR
}

function Write-MyWarning{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host "Error: $message" -ForegroundColor $WARNING_COLOR
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
    Write-Host $message -ForegroundColor $OUTPUT_COLOR
}