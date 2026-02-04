# Include MyWrite.ps1
# Provides Write-MyError, Write-MyWarning, Write-MyVerbose, Write-MyHost, Write-MyDebug
# and Test-MyVerbose, Test-MyDebug functions for consistent logging and debugging output.
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
    [CmdletBinding()]
    [Alias("Write-Error")]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $ERROR_COLOR
    Write-ToConsole "Error: $message" -Color $ERROR_COLOR
}

function Write-MyWarning {
    [CmdletBinding()]
    [Alias("Write-Warning")]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Message
    )
    # Write-Host "Error: $message" -ForegroundColor $WARNING_COLOR
    Write-ToConsole $message -Color $WARNING_COLOR
}

function Write-MyVerbose {
    [CmdletBinding()]
    [Alias("Write-Verbose")]
    param(
        [Parameter(ValueFromPipeline)][string]$Message
    )

    if (Test-MyVerbose) {
        Write-ToConsole $message -Color $VERBOSE_COLOR
    }
}

function Write-MyHost {
    [CmdletBinding()]
    [Alias("Write-Host")]
    param(
        [Parameter(ValueFromPipeline)][string]$Message,
        [Parameter()][string]$ForegroundColor = $OUTPUT_COLOR,
        [Parameter()][switch]$NoNewLine
    )
    # Write-Host $message -ForegroundColor $OUTPUT_COLOR
    Write-ToConsole $message -Color $ForegroundColor -NoNewLine:$NoNewLine
}

function Write-MyDebug {
    [CmdletBinding()]
    [Alias("Write-Debug")]
    param(
        [Parameter(Position = 0)][string]$section,
        [Parameter(Position = 1, ValueFromPipeline)][string]$Message,
        [Parameter(Position = 2)][object]$Object
    )

    process{

        if (Test-MyDebug -section $section) {

            if ($Object) {
                $objString = $Object | Get-ObjetString
                $message = $message + " - " + $objString
            }
            $timestamp = Get-Date -Format 'HH:mm:ss.fff'

            # Write on host
            $logMessage ="[$timestamp][D][$section] $message"

            $logMessage | Write-ToConsole -Color $DEBUG_COLOR
            $logMessage | Write-MyDebugLogging
        }
    }
}

function Write-MyDebugLogging {
    param(
        [Parameter(Position = 1, ValueFromPipeline)][string]$LogMessage
    )

    process{

        $moduleDebugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
        $loggingFilePath = [System.Environment]::GetEnvironmentVariable($moduleDebugLoggingVarName)

        # Check if logging is enabled
        if ([string]::IsNullOrWhiteSpace( $loggingFilePath )) {
            return
        }

        # Check if file exists
        # This should always exist as logging checks for parent path to be enabled
        # It may happen if since enable to execution the parent folder aka loggingFilePath is deleted.
        if(-not (Test-Path -Path $loggingFilePath) ){
            Write-Warning "Debug logging file path not accesible : '$loggingFilePath'"
            return $false
        }

        # Write to log file
        $logFilePath = Join-Path -Path $loggingFilePath -ChildPath "$($MODULE_NAME)_debug.log"
        Add-Content -Path $logFilePath -Value $LogMessage
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


function Test-MyVerbose {
    param(
        [Parameter(Position = 0)][string]$section
    )

    $moduleDebugVarName = $MODULE_NAME + "_VERBOSE"
    $flag = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

    if ([string]::IsNullOrWhiteSpace( $flag )) {
        return $false
    }

    $trace = ($flag -like '*all*') -or ( $section -like "*$flag*")
    return $trace
}

function Enable-ModuleNameVerbose{
    param(
        [Parameter(Position = 0)][string]$section
    )

    if( [string]::IsNullOrWhiteSpace( $section )) {
        $flag = "all"
    } else {
        $flag = $section
    }

    $moduleDebugVarName = $MODULE_NAME + "_VERBOSE"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $flag)
}
Copy-Item -path Function:Enable-ModuleNameVerbose -Destination Function:"Enable-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Enable-$($MODULE_NAME)Verbose"

function Disable-ModuleNameVerbose{
    param()

    $moduleDebugVarName = $MODULE_NAME + "_VERBOSE"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $null)
}
Copy-Item -path Function:Disable-ModuleNameVerbose -Destination Function:"Disable-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Disable-$($MODULE_NAME)Verbose"

function Test-MyDebug {
    param(
        [Parameter(Position = 0)][string]$section,
        [Parameter()][switch]$Logging
    )

    # Get the module debug environment variable
    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    $flag = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

    # check if debugging is enabled
    if ([string]::IsNullOrWhiteSpace( $flag )) {
        return $false
    }

    $flag = $flag.ToLower()
    $section = $section.ToLower()

    $trace = ($flag -like '*all*') -or ( $section -like "*$flag*")
    return $trace
}

function Enable-ModuleNameDebug{
    param(
        [Parameter(Position = 0)][string]$section,
        [Parameter()][string]$LoggingFilePath
    )

    # Check if logging file path is provided
    if( -Not ( [string]::IsNullOrWhiteSpace( $LoggingFilePath )) ) {
        if(Test-Path -Path $LoggingFilePath){
            $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
            [System.Environment]::SetEnvironmentVariable($moduleDEbugLoggingVarName, $LoggingFilePath)
        } else {
            Write-Error "Logging file path '$LoggingFilePath' does not exist. Debug logging will not be enabled."
            return
        }
    }

    # Check section value
    if( [string]::IsNullOrWhiteSpace( $section )) {
        $flag = "all"
    } else {
        $flag = $section
    }

    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $flag)

}
Copy-Item -path Function:Enable-ModuleNameDebug -Destination Function:"Enable-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Enable-$($MODULE_NAME)Debug"

function Disable-ModuleNameDebug {
    param()

    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $null)

    $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
    [System.Environment]::SetEnvironmentVariable($moduleDEbugLoggingVarName, $null)
}
Copy-Item -path Function:Disable-ModuleNameDebug -Destination Function:"Disable-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Disable-$($MODULE_NAME)Debug"

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
