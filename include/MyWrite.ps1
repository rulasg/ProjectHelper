
$ERROR_COLOR = "Red"
$WARNING_COLOR = "Yellow"
$OUTPUT_COLOR = "DarkCyan"
$DEBUG_COLOR = "DarkGray"

function Write-MyError {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $ERROR_COLOR
    Write-ToConsole "Error: $message" -Color $ERROR_COLOR
}

function Write-MyWarning {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $WARNING_COLOR
    Write-ToConsole $message -Color $WARNING_COLOR
}

function Write-MyVerbose {
    param(
        [Parameter(ValueFromPipeline)][string]$Message
    )
    Write-Verbose -Message $message
}

function Write-MyHost {
    param(
        [Parameter(ValueFromPipeline)][string]$Message,
        #NoNewLine
        [Parameter()][switch]$NoNewLine
    )
    # Write-Host $message -ForegroundColor $OUTPUT_COLOR
    Write-ToConsole $message -Color $OUTPUT_COLOR -NoNewLine:$NoNewLine
}

function Write-MyDebug {
    param(
        [Parameter(Position = 0)][string]$section,
        [Parameter(Position = 1, ValueFromPipeline)][string]$Message,
        [Parameter(Position = 2)][object]$Object
    )

    $flag = $env:ProjectHelper_DEBUG

    # Enable debug
    if ([string]::IsNullOrWhiteSpace( $flag )) {
        return
    }

    $trace = ($flag -like '*all*') -or ( $section -like "*$flag*")

    # Write-Host $message -ForegroundColor $DEBUG_COLOR
    if ($trace) {

        if ($Object) {
            $objJson = $Object | ConvertTo-Json -Depth 10 -ErrorAction SilentlyContinue
            $message = $message + " - " + $objJson
        }

        $message = "[DEBUG][$section] " + $message
        Write-ToConsole $message -Color $DEBUG_COLOR
    } 
}

function Write-ToConsole {
    param(
        [Parameter(ValueFromPipeline)][string]$Color,
        [Parameter(ValueFromPipeline, Position = 0)][string]$Message,
        [Parameter()][switch]$NoNewLine

    )
    Write-Host $message -ForegroundColor $Color -NoNewLine:$NoNewLine
}