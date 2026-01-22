
$MockCommandFile = $testRootPath | Join-Path -ChildPath "mockfiles.log"

function Trace-MockCommandFile{
    [CmdletBinding()]
    param(
        [string] $Command,
        [string] $FileName
    )

    # read content
    $content = readMockCommandFile

    # Check that the entry is already there
    $result = $content | Where-Object{$_.command -eq $command}
    if($null -ne $result) {return}

    # add entry
    $new = @{
        Command = $command
        FileName = $fileName
    }

    $ret = @()
    $ret += $content
    $ret += $new

    # Save list
    writeMockCommandFile -Content $ret
}

function readMockCommandFile{
    $ret = Get-Content -Path $MockCommandFile | ConvertFrom-Json

    # return an empty aray if content does not exists
    $ret = $ret ?? @()

    return $ret
}

function writeMockCommandFile($Content){

    $list = $Content | ConvertTo-Json

    $sorted = $list | Sort-Object fileName

    $sorted | Out-File -FilePath $MockCommandFile
}