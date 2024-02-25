# Managing dependencies
$MODULE_INVOKATION_TAG = "ProjectHelperModule_Mock"
$ROOT = $PSScriptRoot | Split-Path -Parent
$MOCK_PATH = $ROOT | Join-Path -ChildPath 'private' -AdditionalChildPath 'mocks'


function Set-InvokeCommandMock{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG
} 

function Reset-InvokeCommandMock{
    [CmdletBinding()]
    param()

    InvokeHelper\Reset-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG
} Export-ModuleMember -Function Reset-InvokeCommandMock

function MockCall{
    param(
        [string] $command,
        [string] $filename

    )

    $mockFile = $MOCK_PATH | Join-Path -ChildPath $filename
    Set-InvokeCommandMock -Alias $command -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"
}

function MockCallToString{
    param(
        [string] $command,
        [string] $OutString
    )

    $outputstring = 'echo "{output}"'
    $outputstring = $outputstring -replace "{output}", $OutString

    Set-InvokeCommandMock -Alias $command -Command $outputstring
}

function MockCallToNull{
    param(
        [string] $command
    )

    Set-InvokeCommandMock -Alias $command -Command 'return $null'
}

function MockCallThrow{
    param(
        [string] $command

    )
    Set-InvokeCommandMock -Alias $command -Command "throw"
}

Reset-InvokeCommandMock