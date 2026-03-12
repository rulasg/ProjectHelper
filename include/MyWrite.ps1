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

    Write-MyDebug -Section "MyHost" -Message $Message

    # Write-Host $message -ForegroundColor $OUTPUT_COLOR
    Write-ToConsole $message -Color $ForegroundColor -NoNewLine:$NoNewLine
}

function Clear-MyHost {
    [CmdletBinding()]
    param()

    Clear-Host
}

function Write-MyDebug {
    [CmdletBinding()]
    [Alias("Write-Debug")]
    param(
        [Parameter(Position = 0)][string]$section = "none",
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
            $logMessage ="[$timestamp][$MODULE_NAME][D][$section] $message"

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

        $loggingFilePath = get-DebugLogFile

        # Check if logging is enabled
        if ([string]::IsNullOrWhiteSpace( $loggingFilePath )) {
            return
        }

        # Check if file exists
        # This should always exist as logging checks for parent path to be enabled
        # It may happen if since enable to execution the parent folder aka loggingFilePath is deleted.
        if(-not (Test-Path -Path $loggingFilePath -PathType Leaf) ){
            Write-Warning "Debug logging file path not accesible : '$loggingFilePath'"
            return $false
        }

        # Write to log file
        Add-Content -Path $loggingFilePath -Value $LogMessage
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

    $flag = get-VerboseSections

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

    set-VerboseSections $flag
}
Copy-Item -path Function:Enable-ModuleNameVerbose -Destination Function:"Enable-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Enable-$($MODULE_NAME)Verbose"

function Disable-ModuleNameVerbose{
    param()

    set-VerboseSections $null
}
Copy-Item -path Function:Disable-ModuleNameVerbose -Destination Function:"Disable-$($MODULE_NAME)Verbose"
Export-ModuleMember -Function "Disable-$($MODULE_NAME)Verbose"

function Test-MyDebug {
    param(
        [Parameter(Position = 0)][string]$section,
        [Parameter()][switch]$Logging
    )

    function testSection($section,$flags){
        if($flags.Count -eq 0){
            return $false
        }
        $flags = $flags.ToLower()
        $section = $section.ToLower()

        return ($flags.Contains("all")) -or ( $flags -eq $section)
    }


    $sectionsString = get-DebugSections

    # No configuration means no debug
    if([string]::IsNullOrWhiteSpace( $sectionsString )) {
        return $false
    }

    # Get flags from sectionsString
    $flags = getSectionsFromSectionsString $sectionsString

    # Add all if allow is empty. 
    # This mean stat flagsString only contains filters.
    $flags.allow = $flags.allow.Count -eq 0 ? @("all") : $flags.allow

    # Get the module debug environment variable
    $isAllow = testSection -Section:$section -Flags:$flags.allow
    $isFiltered = testSection -Section:$section -Flags:$flags.filter
    
    $trace = $isAllow -and -not $isFiltered

    return $trace
}

function Enable-ModuleNameDebug{
    param(
        [Parameter(Position = 0)][string[]]$Sections,
        [Parameter()][string[]]$AddSections,
        [Parameter()][string]$LoggingFilePath
    )

    # Check if logging file path is provided
    if( -Not ( [string]::IsNullOrWhiteSpace( $LoggingFilePath )) ) {
        if(Test-Path -Path $LoggingFilePath -PathType Leaf){
            set-LogFile $LoggingFilePath
        } else {
            Write-Error "Logging file path '$LoggingFilePath' does not exist. Debug logging will not be enabled."
            return
        }
    }

    $sectionsString = $sections -join " "
    $addedFlagsString = $AddSections -join " "

    # if no section get value from env and is still mepty set to all
    if([string]::IsNullOrWhiteSpace( $sectionsString )) {
        $sectionsString = get-DebugSections
        if( [string]::IsNullOrWhiteSpace( $sectionsString )) {
            $sectionsString = "all"
        }
    }
    
    # Add added to sectionsString if provided
    if(-Not [string]::IsNullOrWhiteSpace( $addedFlagsString )) {
        $sectionsString += " " + $addedFlagsString
    }

    set-DebugSections $sectionsString

}
Copy-Item -path Function:Enable-ModuleNameDebug -Destination Function:"Enable-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Enable-$($MODULE_NAME)Debug"

function getSectionsFromSectionsString($sectionsString){
    $sections = @{
        allow = $null
        filter = $null
    }

    if([string]::IsNullOrWhiteSpace($sectionsString) ){
        $sections.allow = @("all")
        return $sections
    }

    $list = $sectionsString.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)

    $split = @($list).Where({ $_ -like '-*' }, 'Split')

    $sections.filter = $split[0] | ForEach-Object { $_ -replace '^-', '' }  # -> API, Auth
    $sections.allow = $split[1]  # -> Sync, Cache

    return $sections
}

function Disable-ModuleNameDebug {
    param()

    set-DebugSections $null
    set-LogFile $null
}
Copy-Item -path Function:Disable-ModuleNameDebug -Destination Function:"Disable-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Disable-$($MODULE_NAME)Debug"

function Get-ModuleNameDebug {
    [cmdletbinding()]
    param()

    return @{
        Sections = get-DebugSections
        LoggingFilePath = get-DebugLogFile
    }
}
Copy-Item -path Function:Get-ModuleNameDebug -Destination Function:"Get-$($MODULE_NAME)Debug"
Export-ModuleMember -Function "Get-$($MODULE_NAME)Debug"

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

function get-Sections(){
    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    $sections = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

    return $sections
}

function set-Sections($sections){
    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $sections)
}

function get-LogFile(){
    $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
    $logfile = [System.Environment]::GetEnvironmentVariable($moduleDEbugLoggingVarName)

    return $logfile
}

function set-LogFile($logFilePath){
    $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
    [System.Environment]::SetEnvironmentVariable($moduleDEbugLoggingVarName, $logFilePath)
}

function get-DebugSections(){
    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    $sections = [System.Environment]::GetEnvironmentVariable($moduleDebugVarName)

    return $sections
}

function set-DebugSections($sections){
    $moduleDebugVarName = $MODULE_NAME + "_DEBUG"
    [System.Environment]::SetEnvironmentVariable($moduleDebugVarName, $sections)
}

function get-DebugLogFile(){
    $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
    $logfile = [System.Environment]::GetEnvironmentVariable($moduleDEbugLoggingVarName)

    return $logfile
}

function set-LogFile($logFilePath){
    $moduleDEbugLoggingVarName = $MODULE_NAME + "_DEBUG_LOGGING_FILEPATH"
    [System.Environment]::SetEnvironmentVariable($moduleDEbugLoggingVarName, $logFilePath)
}

function get-VerboseSections{
    $moduleVerboseVarName = $MODULE_NAME + "_VERBOSE"
    $sections = [System.Environment]::GetEnvironmentVariable($moduleVerboseVarName)

    return $sections
}

function set-VerboseSections($sections){
    $moduleVerboseVarName = $MODULE_NAME + "_VERBOSE"
    [System.Environment]::SetEnvironmentVariable($moduleVerboseVarName, $sections)
}