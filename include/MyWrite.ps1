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
Rename-Item -path Function:Enable-ModuleNameVerbose -NewName "Set-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Set-$($MODULE_NAME)Verbose"

function Disable-ModuleNameVerbose{
    param()

    $moduleDebugVarName = $MODULE_NAME + "_VERBOSE"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $null)
}
Rename-Item -path Function:Disable-ModuleNameVerbose -NewName "Clear-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Clear-$($MODULE_NAME)Verbose"

function Test-MyDebug {
    param(
        [Parameter(Position = 0)][string]$section
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
        [Parameter(Position = 0)][string]$section
    )

    if( [string]::IsNullOrWhiteSpace( $section )) {
        $flag = "all"
    } else {
        $flag = $section
    }

    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $flag)
}
Rename-Item -path Function:Enable-ModuleNameDebug -NewName "Enable-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Enable-$($MODULE_NAME)Debug"

function Disable-ModuleNameDebug {
    param()

    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $null)
}
Rename-Item -path Function:Disable-ModuleNameDebug -NewName "Disable-$($MODULE_NAME)Debug"
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





