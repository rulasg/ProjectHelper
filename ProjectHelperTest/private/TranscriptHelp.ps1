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
    Stop-Transcript
    $transcriptContent = Get-Content -Path $TEST_TRANSCRIPT_FILE
    Remove-Item -Path $TEST_TRANSCRIPT_FILE
    return $transcriptContent
}