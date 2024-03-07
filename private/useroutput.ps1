function Write-MyError{
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Message
    )
    Write-Host "Error: $message" -ForegroundColor Red

}