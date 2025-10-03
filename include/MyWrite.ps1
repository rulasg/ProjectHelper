
$ERROR_COLOR = "Red"
$WARNING_COLOR = "Yellow"
$VERBOSE_COLOR = "DarkYellow"
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

    Write-ToConsole $message -Color $VERBOSE_COLOR
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

    if (Test-Debug -section $section) {


        if ($Object) {
            $objString = $Object | Get-ObjetString
            $message = $message + " - " + $objString
        }
        $timestamp = Get-Date -Format 'HH:mm:ss.fff'
        "[$timestamp][D][$section] $message" | Write-ToConsole -Color $DEBUG_COLOR
    } 
}

function Write-ToConsole {
    param(
        [Parameter(ValueFromPipeline)][string]$Color,
        [Parameter(ValueFromPipeline, Position = 0)][string]$Message,
        [Parameter()][switch]$NoNewLine

    )
    Microsoft.PowerShell.Utility\Write-Host $message -ForegroundColor $Color -NoNewLine:$NoNewLine
}

function Test-Debug {
    param(
        [Parameter(Position = 0)][string]$section
    )

    $flag = $env:ProjectHelper_DEBUG

    # Enable debug
    if ([string]::IsNullOrWhiteSpace( $flag )) {
        return $false
    }

    $trace = ($flag -like '*all*') -or ( $section -like "*$flag*")
    return $trace
}

function Get-ObjetString {
    param(
        [Parameter(ValueFromPipeline, Position = 0)][object]$Object
    )

    process{

        if ($null -eq $Object) {
            return "null"
        }
        
        if ($Object -is [string]) {
            return $Object
        }
        
        return $Object | ConvertTo-Json -Depth 10 -ErrorAction SilentlyContinue
    }
}