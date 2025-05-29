<#
.SYNOPSIS
    Updates project items with injection functions.
.DESCRIPTION
    This function updates items in a project using defined injection functions.
.PARAMETER Owner
    The owner of the project.
.PARAMETER ProjectNumber
    The project number.
.PARAMETER IncludeDoneItems
    If specified, includes items that are marked as done.
.PARAMETER SkipProjectSync
    If specified, skips the project synchronization step.
.EXAMPLE
    Update-ProjectItemsWithInjection -Owner "octodemo" -ProjectNumber 164
    This will call all commands available called Invoke-ProjectInjection_* to update items in the project owned by "octodemo" with the project number 164.
#>
function Update-ProjectItemsWithInjection{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()] [switch]$IncludeDoneItems,
        [Parameter()] [switch]$SkipProjectSync
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    if((-not $SkipProjectSync) -AND (Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber)){
        "Project has staged items, please Sync-ProjectItemStaged or Reset-ProjectItemStaged and try again" | Write-Error
        return
    }

    # Get the project
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:(-not $SkipProjectSync)

    # Get the injection functions list

    $functions = Get-Command -Name "Invoke-ProjectInjection_*" -ErrorAction SilentlyContinue

    # Iterate through all the items in the project
    $start = Get-Date
    $result = $functions | Invoke-ProjectInjection -Owner $Project.owner -ProjectNumber $Project.number -ShowErrors
    $time = ($start | New-TimeSpan ).ToString("hh\:mm\:ss\:FFFF")

    # Add extra info to result
    $result | Add-Member -NotePropertyName "Integrations" -NotePropertyValue $functions.count
    $result | Add-Member -NotePropertyName "Time" -NotePropertyValue $time
    $result | Add-Member -NotePropertyName "IntegrationsName" -NotePropertyValue $functions.Name


    # Save result to global variable
    $global:ResultUpdateProjectWithInjection = $result

    # Displayy all results strucutre
    return $global:ResultUpdateProjectWithInjection

} Export-ModuleMember -Function Update-ProjectItemsWithInjection


<#.SYNOPSIS
    Invokes a project injection function for a specific project.
.DESCRIPTION
    This function invokes a project injection function for a specific project, allowing for integration with various project management tasks.
.PARAMETER FunctionInfo
    The function information to be invoked.
    We use this parameter to pipe the output of Get-Command to this function.
.PARAMETER FunctionName
    The name of the function to be invoked.
    If this parameter is not provided, the FunctionInfo parameter must be provided.
    If this parameter is provided, the FunctionInfo parameter will be ignored.
.PARAMETER Owner
    The owner of the project.
.PARAMETER ProjectNumber
    The project number.
.PARAMETER ShowErrors
    If specified, shows errors encountered during the function invocation.
.EXAMPLE
    Invoke-ProjectInjection -FunctionName "Invoke-ProjectInjection_UpdateItemsStatusOnDueDate" -Owner "octodemo" -ProjectNumber 164
    This will invoke the function "Invoke-ProjectInjection_UpdateItemsStatusOnDueDate" for the project owned by "octodemo" with the project number 164.
.NOTES
    This function will allow to single pick the injection function to call under the development of integrations for later be called by Update-ProjectItemsWithInjection.
#>
function Invoke-ProjectInjection {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][System.Management.Automation.FunctionInfo] $FunctionInfo,
        [Parameter()] [string] $FunctionName,
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter()] [switch] $ShowErrors
    )

    begin{
        ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber

        $ret = @{
            FailedIntegration = @()
            FailedIntegrationErrors = @{}
            NotImplementedIntegration = @()
            SkippedIntegration = @()
        }
    }

    Process {

        if ($ShowErrors) {
            $ErrorShow = 'Continue'
        }
        else {
            $ErrorShow = 'SilentlyContinue'
        }

        if ($FunctionInfo) {
            $FunctionName = $FunctionInfo.Name
        } elseif (-not $FunctionName) {
            Write-Error "FunctionName is required when FunctionInfo is not provided."
            return
        }

        Write-Verbose -Message "Running [ $FunctionName ]"

        try {
            Write-Host "$FunctionName ... [" -ForegroundColor DarkCyan
            $null = & $FunctionName -Owner $Owner -ProjectNumber $ProjectNumber -ErrorAction $ErrorShow
            Write-Host "] "  -NoNewline -ForegroundColor DarkCyan
            Write-Host "PASS"  -ForegroundColor DarkYellow
            $ret.Pass++
        }
        catch {
    
            Write-Host "x"  -NoNewline -ForegroundColor Red 
            Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 

            if ($_.Exception.Message -eq "SKIP_INTEGRATION") {
                Write-Host "Skip"  -ForegroundColor Magenta
                $ret.SkippedIntegration += $FunctionName
                
            }elseif ($_.Exception.Message -eq "NOT_IMPLEMENTED") {
                Write-Host "NotImplemented"  -ForegroundColor Red
                $ret.NotImplementedIntegration += $FunctionName
                
            } else {
                Write-Host "Failed"  -ForegroundColor Red 
                $ret.FailedIntegration += $FunctionName
                
                $ret.FailedIntegrationErrors.$functionName = $_
                
                if ($ShowErrors) {
                    
                    $functionName | Write-Host -ForegroundColor Red
                    $_ | Write-Host -ForegroundColor Red
                } 
            }
        }
    }

    end{

        if($ret.FailedIntegration.count -eq 0)         { $ret.Remove("FailedIntegration")}         else {$ret.Failed = $ret.FailedIntegration.Count}
        if($ret.SkippedIntegration.count -eq 0)        { $ret.Remove("SkippedIntegration")}        else {$ret.Skipped = $ret.SkippedIntegration.Count}
        if($ret.NotImplementedIntegration.count -eq 0) { $ret.Remove("NotImplementedIntegration")} else {$ret.NotImplemented = $ret.NotImplementedIntegration.Count}

        if($ret.FailedIntegrationErrors.count -eq 0) { $ret.Remove("FailedIntegrationErrors")}

        $Global:FailedIntegrationErrors = $ret.FailedIntegrationErrors

        return [PSCustomObject] $ret
    }
} Export-ModuleMember -Function Invoke-ProjectInjection