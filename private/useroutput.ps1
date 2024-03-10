
$ERROR_COLOR = "Red"
$OUTPUT_COLOR = "DarkCyan"

function Write-MyError{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host "Error: $message" -ForegroundColor $ERROR_COLOR

}

function Write-MyVerbose{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Verbose -Message $message
}

function Write-MyHost{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host $message -ForegroundColor $OUTPUT_COLOR
}