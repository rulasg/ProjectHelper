#Module path is where resides the RootModule file. This file. :)
$MODULE_PATH = $PSScriptRoot

# Import START
$START = $MODULE_PATH | Join-Path -ChildPath "private" -AdditionalChildPath 'START.ps1'
if($START | Test-Path){ . $($START | Get-Item).FullName }

#Get public and private function definition files.
$include = @( Get-ChildItem -Path $MODULE_PATH\include\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $MODULE_PATH\private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Public  = @( Get-ChildItem -Path $MODULE_PATH\public\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($include + $Private + $Public))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

