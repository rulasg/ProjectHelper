
Set-InvokeCommandAlias -Alias "GetDateToday" -Command "Get-Date -Format yyyy-MM-dd"

function Get-DateToday{
    [CmdletBinding()]
    param()
    
    $today = Invoke-MyCommand -Command GetDateToday

    return $today
}