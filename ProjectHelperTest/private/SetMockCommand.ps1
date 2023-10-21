
# Global variable that holds the commands to call gh cli by the module
$global:OutputData = @{}

<#  
.SYNOPSIS
    Replaces the default Gh Cli Command Invoke with a Mocked one
.DESCRIPTION
    For testing we can mock the Gh Cli Command Invoke with a Mocked one
    returing $outputData as the output of the call.
    We will replace $global.CommandList.$CommandName entry to a mocked command.
#>
function Set-MockCommand{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter()][string]$OutputData
    )

    $global:OutputData.$CommandName = $OutputData

    $injectedData = '$global:OutputData.{commandName}' -replace '{commandName}',$CommandName

    $global:CommandList.$CommandName = "echo $injectedData"
}

function Set-MockCommandWithFileData{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter()][string]$FileName
    )

    $mocksRoot = Get-MockFilePath
    
    # Check if FileName is emtpy or whitespace
    $FileName = ([string]::IsNullOrWhiteSpace($FileName)) ? "$($CommandName.ToLower()).*" : $FileName

    $file = Get-Item $($mocksRoot | Join-Path -ChildPath "$filename" )

    if($null -eq $file){
        throw "File [$FileName] not found"
    }

    # check more than one file found
    if($file.Count -gt 1){
        throw "More than one file found for [$FileName]"
    }

    $global:CommandList.$CommandName = "Get-Content -Path $file"
}

function Get-MockFilePath{
    return $PSScriptRoot | Join-Path -ChildPath "mocks"
}