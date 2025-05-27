<#
.SYNOPSIS
    Update all the items of a project with an integration command
.DESCRIPTION
    Update all the items of a project with an integration command
    The function will update all the items of a project with the values returned by the integration command
    The integration command will be called for each Item with the value of the integration field as parameter.
    The integration command must return a hashtable with the values to be updated
    The project fields to be updated will have the same name as the hash table keys with a slug as suffix
    If an item has a field with the name `sf_Name` it will be updated with the value of the hashtable key Name if the slug defined is "sf_"
.EXAMPLE
    Update-ProjectItemsWithIntegration -Owner "someOwner" -ProjectNumber 164 -IntegrationField "sfUrl" -IntegrationCommand "Get-SfAccount" -Slug "sf_"
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
        $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

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
            Write-Host "$FunctionName ... [" -NoNewline -ForegroundColor DarkCyan
            $null = & $FunctionName -Project $Project -ErrorAction $ErrorShow
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