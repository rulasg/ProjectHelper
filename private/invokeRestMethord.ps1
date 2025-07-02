
function Invoke-RestMethod{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Method,
        [Parameter(Position = 1)][string]$Uri,
        [Parameter(Position = 2)][hashtable]$Headers,
        [Parameter(Position = 3)][string]$Body,
        [Parameter()][string]$Outfile
    )

    $params = @{
        Method = $Method
        Uri = $Uri
        Headers = $Headers
        Body = $Body
    }
    if($Outfile){
        $params.OutFile = $Outfile
    }

    $result = Microsoft.PowerShell.Utility\Invoke-RestMethod @params

    return $result
}