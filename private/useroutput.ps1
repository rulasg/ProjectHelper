function Write-MyError{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host "Error: $message" -ForegroundColor Red

}

function Write-MyVerbose{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Verbose -Message $message
}