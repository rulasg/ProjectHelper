
# INVOKE COMMAND MOCK
#
# This includes help commands to mock invokes in a test module
#
# THIS INCLUDE REQURED module.helper.ps1
if(-not $MODULE_NAME){ throw "Missing MODULE_NAME varaible initialization. Check for module.helerp.ps1 file." }
if(-not $MODULE_ROOT_PATH){ throw "Missing MODULE_ROOT_PATH varaible initialization. Check for module.helerp.ps1 file." }


$testRootPath = $MODULE_ROOT_PATH | Join-Path -ChildPath 'Test'
$MOCK_PATH = $testRootPath | Join-Path -ChildPath 'private' -AdditionalChildPath 'mocks'

$MODULE_INVOKATION_TAG = "$($MODULE_NAME)Module"
$MODULE_INVOKATION_TAG_MOCK = "$($MODULE_INVOKATION_TAG)_Mock"

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

function MockCallAsync{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $filename
    )

    Assert-MockFileNotfound $fileName

    $moduleTest = $PSScriptRoot | Split-Path -Parent | Convert-Path

    Set-InvokeCommandMock -Alias $command -Command "Import-Module $moduleTest ; Get-MockFileContent -filename $filename"
}

function MockCallJson{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $filename,
        [Parameter()][switch] $AsHashtable

    )

    Assert-MockFileNotfound $fileName
    $asHashTableString = $AsHashtable ? '$true' : '$false'

    $commandstr ='Get-MockFileContentJson -filename {filename} -AsHashtable:{asHashTableString}'
    $commandstr = $commandstr -replace "{asHashTableString}", $asHashTableString
    $commandstr = $commandstr -replace "{filename}", $filename

    Set-InvokeCommandMock -Alias $command -Command $commandstr
}

function MockCallJsonAsync{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $filename

    )

    Assert-MockFileNotfound $fileName

    $moduleTest = $PSScriptRoot | Split-Path -Parent | Convert-Path

    Set-InvokeCommandMock -Alias $command -Command "Import-Module $moduleTest ; Get-MockFileContentJson -filename $filename"
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
        [parameter(Mandatory,Position=0)][string] $fileName,
        [Parameter()][switch] $AsHashtable
    )

    Assert-MockFileNotfound $FileName

    $content = Get-MockFileContent -fileName $filename | ConvertFrom-Json -AsHashtable:$AsHashtable -Depth 100

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

function MockCallExpression{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=1)][string] $expression
    )

    $mockCommand = @'
    Invoke-Expression -Command '{expression}'
'@
    $mockCommand = $mockCommand -replace "{expression}", $expression

    Set-InvokeCommandMock -Alias $command -Command $expression
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



