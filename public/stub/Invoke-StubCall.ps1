function Invoke-StubCall{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $stubName,
        [Parameter(Mandatory)][hashtable] $Parameters
    )

    switch ($stubName) {
        "Stub_GetProjectItem" { $ret = Get-BaseProjectItem @Parameters }
        "Stub_ShowProjectItem" { $ret = Show-BaseProjectItem @Parameters }
        "Stub_ShowProjectTodo"{ $ret = Show-BaseProjectTodo @Parameters }

        default { throw "Unknown stub name: $stubName" }
    }

    return $ret

} Export-ModuleMember -Function Invoke-StubCall

function Invoke-StubCall_Common{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $stubName,
        [Parameter(Mandatory)][hashtable] $Parameters
    )

    "[Invoke-StubCall_Common] Invoking stub call for [$stubName] >>> " | Write-MyDebug -Section "Invoke-StubCall_Common" -Object $Parameters
    
    switch ($stubName) {
        "Stub_GetProjectItem" { $ret = Get-BaseProjectItem @Parameters }
        
        "Stub_ShowProjectItem" {
            # Using Show-SalesProjectItem until I code the proper Common stub for Show-ProjectItem
            # Create a Show-CommonProjectItem that shows common fields based on ProjectConfig (Comment,DueDate)
            $owner,$ProjectNumber = Resolve-ProjectParameters -Owner $Parameters.Owner -ProjectNumber $Parameters.ProjectNumber -doNotThrow
            $Parameters.Owner = $owner ; $Parameters.ProjectNumber = $ProjectNumber
            $ret = SalesHelper\Show-SalesProjectItem @Parameters
        }

        "Stub_ShowProjectTodo"{ $ret = Show-BaseProjectTodo @Parameters }

        default { throw "Unknown stub name: $stubName" }
    }
    
    "[Invoke-StubCall_Common] Invoking stub call for [$stubName] <<< " | Write-MyDebug -Section "Invoke-StubCall_Common" -Object $ret

    return $ret

} Export-ModuleMember -Function Invoke-StubCall_Common