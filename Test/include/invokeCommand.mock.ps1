
# INVOKE COMMAND MOCK
#
# This includes help commands to mock invokes in a test module
# You need to set the following variables
# $MODULE_INVOKATION_TAG : name of the module that you are testing. This needs to match with the Tag used in the module you are testing.
# $MODULE_INVOKATION_TAG_MOCK : Tag for the mock functions on the testing moodule you are loading this include in
# MOCK_PATH : path to the mocks folder. This is where the mock files will be saved and loaded from.
#
# Sample:
# $MODULE_INVOKATION_TAG = "SfHelperModule"
# $MODULE_INVOKATION_TAG_MOCK = "SfHelperModule-Mock"
# $MOCK_PATH = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'private' -AdditionalChildPath 'mocks'

# Managing dependencies
$MODULE_INVOKATION_TAG = "ProjectHelperModule"
$MODULE_INVOKATION_TAG_MOCK = "ProjectHelperModule_Mock"
$ROOT = $PSScriptRoot | Split-Path -Parent
$MOCK_PATH = $ROOT | Join-Path -ChildPath 'private' -AdditionalChildPath 'mocks'


function Set-InvokeCommandMock{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG_MOCK
} 

function Reset-InvokeCommandMock{
    [CmdletBinding()]
    param()

    # Remove all mocks
    InvokeHelper\Reset-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG_MOCK

    # Disable all dependecies of the library
    Disable-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG

    # Clear Enviroment variables used
    Get-Variable -scope Global -Name "$($MODULE_INVOKATION_TAG_MOCK)_*"  | Remove-Variable -Force -Scope Global

} Export-ModuleMember -Function Reset-InvokeCommandMock

function Enable-InvokeCommandAliasModule{
    [CmdletBinding()]
    param()

    Enable-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG
} Export-ModuleMember -Function Enable-InvokeCommandAliasModule

function MockCall{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $filename
    )

    Assert-MockFileNotfound $fileName

    Set-InvokeCommandMock -Alias $command -Command "Get-MockFileContent -filename $filename"
}

function MockCallJson{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $filename

    )

    Assert-MockFileNotfound $fileName

    Set-InvokeCommandMock -Alias $command -Command "Get-MockFileContentJson -filename $filename"
}

function Get-MockFileFullPath{
    param(
        [parameter(Mandatory,Position=0)][string] $fileName
    )

    $filePath = $MOCK_PATH | Join-Path -ChildPath $fileName

    return $filePath
} Export-ModuleMember -Function Get-MockFileFullPath

function Get-MockFileContent{
    param(
        [parameter(Mandatory,Position=0)][string] $fileName
    )

    Assert-MockFileNotfound $FileName

    $filePath = Get-MockFileFullPath -fileName $fileName

    $content = Get-Content -Path $filePath | Out-String

    return $content
} Export-ModuleMember -Function Get-MockFileContent

function Get-MockFileContentJson{
    param(
        [parameter(Mandatory,Position=0)][string] $fileName
    )

    Assert-MockFileNotfound $FileName

    $content = Get-MockFileContent -fileName $filename | ConvertFrom-Json

    return $content
} Export-ModuleMember -Function Get-MockFileContentJson

function MockCallToString{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $OutString
    )

    $outputstring = 'echo "{output}"'
    $outputstring = $outputstring -replace "{output}", $OutString

    Set-InvokeCommandMock -Alias $command -Command $outputstring
}


function MockCallToObject{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][object] $OutObject
    )

    $random = [System.Guid]::NewGuid().ToString()
    $varName = "$MODULE_INVOKATION_TAG_MOCK" + "_$random"

    Set-Variable -Name $varName -Value $OutObject -Scope Global

    Set-InvokeCommandMock -Alias $command -Command "(Get-Variable -Name $varName -Scope Global).Value"

}

function MockCallToNull{
    param(
        [Parameter(Position=0)][string] $command
    )

    Set-InvokeCommandMock -Alias $command -Command 'return $null'
}

function MockCallThrow{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $ExceptionMessage

    )

    $mockCommand = 'throw "{message}"'
    $mockCommand = $mockCommand -replace "{message}", $exceptionMessage

    Set-InvokeCommandMock -Alias $command -Command $mockCommand
}

function Save-InvokeAsMockFile{
    param(
        [Parameter(Mandatory=$true)] [string]$Command,
        [Parameter(Mandatory=$true)] [string]$FileName,
        [Parameter(Mandatory=$false)] [switch]$Force
    )

    $filePath = Get-MockFileFullPath -fileName $fileName

    $result = Invoke-Expression -Command $Command

    $json = $result | ConvertTo-Json -Depth 100 
    
    $json | Out-File -FilePath $filePath

    Write-Host $FileName
} Export-ModuleMember -Function Save-InvokeAsMockFile

function Save-InvokeAsMockFileJson{
    param(
        [Parameter(Mandatory=$true)] [string]$Command,
        [Parameter(Mandatory=$true)] [string]$FileName
    )

    $filePath = Get-MockFileFullPath -fileName $fileName

    $result = Invoke-Expression -Command $Command

    $result | Out-File -FilePath $filePath

    Write-Host $FileName
} Export-ModuleMember -Function Save-InvokeAsMockFileJson

function Assert-MockFileNotfound{
    param(
        [Parameter(Mandatory=$true,Position=0)] [string]$FileName
    )

    $filePath = Get-MockFileFullPath -fileName $fileName

    if(-Not (Test-Path -Path $filePath)){
        throw "File not found: $fileName"
    }

    # Throw if $file.name and the $filename parameter have different case
    # We need to check this to avoid test bugs for mock files not found on linux that the FS is case sensitive
    $file = Get-ChildItem -Path $MOCK_PATH | Where-Object { $_.Name.ToLower() -eq $fileName.ToLower() }
    if($file.name -cne $fileName){
        Write-host "Wait-Debugger - File not found or wrong case - $($file.name)"
        Wait-Debugger
        throw "File not found or wrong case name. Expected[ $filename ] - Found[$( $file.name )]"
    }
}