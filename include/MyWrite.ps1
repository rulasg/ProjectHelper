# Include MyWrite.ps1
# Provides Write-MyError, Write-MyWarning, Write-MyVerbose, Write-MyHost, Write-MyDebug
# and Test-Verbose, Test-Debug functions for consistent logging and debugging output.
# Use env variables ModuleHelper_VERBOSE and ModuleHelper_DEBUG to control verbosity and debug output.
# Example: $env:ModuleHelper_DEBUG="all" or $env:ModuleHelper_DEBUG="Sync-Project"

$ModuleRootPath = Get-ModuleRootPath -ModuleRootPath $ModuleRootPath
$MODULE_NAME = (Get-ChildItem -Path $ModuleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName

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

    if (Test-Verbose) {
        Write-ToConsole $message -Color $VERBOSE_COLOR
    }
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

    process{

        if (Test-Debug -section $section) {

            if ($Object) {
                $objString = $Object | Get-ObjetString
                $message = $message + " - " + $objString
            }
            $timestamp = Get-Date -Format 'HH:mm:ss.fff'
            "[$timestamp][D][$section] $message" | Write-ToConsole -Color $DEBUG_COLOR
        }
    }
}

function Write-ToConsole {
    param(
        [Parameter(ValueFromPipeline)][string]$Color,
        [Parameter(ValueFromPipeline, Position = 0)][string]$Message,
        [Parameter()][switch]$NoNewLine

    )
    if([string]::IsNullOrWhiteSpace($Color)){
        Microsoft.PowerShell.Utility\Write-Host $message -NoNewLine:$NoNewLine
    } else {
        Microsoft.PowerShell.Utility\Write-Host $message -ForegroundColor:$Color -NoNewLine:$NoNewLine
    }

}


function Test-Verbose {
    param(
        [Parameter(Position = 0)][string]$section
    )

    $moduleDebugVarName = $MODULE_NAME + "_VERBOSE"
    $flag = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

    # Enable debug
    if ([string]::IsNullOrWhiteSpace( $flag )) {
        return $false
    }

    $trace = ($flag -like '*all*') -or ( $section -like "*$flag*")
    return $trace
}

function Test-Debug {
    param(
        [Parameter(Position = 0)][string]$section
    )

    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    $flag = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

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