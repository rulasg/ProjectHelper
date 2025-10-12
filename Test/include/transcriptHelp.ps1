# Test Transcript helper functions
# These functions help manage the transcript file during tests
# and ensure it is cleaned up after use.


$TEST_TRANSCRIPT_FILE = "test_transcript.log"

function Start-MyTranscript {
    [CmdletBinding()]
    param ()

    if (Test-Path $TEST_TRANSCRIPT_FILE) {
        Remove-Item -Path $TEST_TRANSCRIPT_FILE -Force
    }

    Start-Transcript -Path $TEST_TRANSCRIPT_FILE
}

function Stop-MyTranscript {
    
    $null = Stop-Transcript

    $transcriptContent = Get-Content -Path $TEST_TRANSCRIPT_FILE
    Remove-Item -Path $TEST_TRANSCRIPT_FILE

    $ret = Export-MyTranscript -transcriptContent $transcriptContent

    return $ret
}

function Export-MyTranscript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string[]]$transcriptContent
    )

    $i = 0..($transcriptContent.Count - 1) | Where-Object { $transcriptContent[$_] -eq "**********************" }

    $firstLine = $i[1] + 1
    $lastLine = $i[2] - 1

    $retlist = $transcriptContent[$firstLine..$lastLine]
        
    return $retlist
}

