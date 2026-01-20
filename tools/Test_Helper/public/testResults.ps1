function Test-Result{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][object]$Result,
        [Parameter()][switch]$SkippedNotAllowed,
        [Parameter()][switch]$NotImplementedNotAllowed
    )

    # Chek results from last run
    $Result = $Result ?? $Global:ResultTestingHelper

    if($SkippedNotAllowed -and $Result.Skipped -gt 0){
        return $false
    }

    if($NotImplementedNotAllowed -and $Result.NotImplemented -gt 0){
        return $false
    }

    # Allow Not Implemented and Skipped tests to pass
    $passed = $Result.Tests -eq $Result.Pass + $Result.NotImplemented + $Result.Skipped

    return $passed
} Export-ModuleMember -Function Test-Result
