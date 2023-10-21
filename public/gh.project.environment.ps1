
<#
.Synopsis 
GitHub Project functions that shows Enviroment variables used on GH Projects commands
#>
function Get-GhPEnvironment{
    [CmdletBinding()]
    [Alias("gghpe")]
    param(
    )

    $ret = @{
        Owner = $env:GHP_OWNER ?? 'null'
        ProjectTitle = $env:GHP_PROJECT_TITLE ?? 'null'
        ProjectNumber = $env:GHP_PROJECT_NUMBER ?? 'null'
        # Id = $env:GHP_PROJECT_ID ?? 'null'
    }

    return $ret

} Export-ModuleMember -Function Get-GhPEnvironment -Alias gghpe

<#
.Synopsis
Sets environment variables for GH Projects commands
#>
function Set-GhPEnvironment{
    [CmdletBinding()]
    [Alias("sghpe")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ProjectTitle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][int]$ProjectNumber,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Owner,
        #passthrough
        [Parameter()][switch]$PassThru
    )

     $env:GHP_OWNER = $Owner
     $env:GHP_PROJECT_TITLE = $ProjectTitle
     $env:GHP_PROJECT_NUMBER = $ProjectNumber
    #  $env:GHP_PROJECT_ID = $Id

    if($PassThru){
        return Get-GhPEnvironment
    }
} Export-ModuleMember -Function Set-GhPEnvironment -Alias sghpe

<#
.Synopsis
Clears environment variables for GH Projects commands
#>
function Clear-GhPEnvironment{
    [CmdletBinding()]
    param(
    )

    $env:GHP_OWNER = "null"
    $env:GHP_PROJECT_TITLE = "null"
    $env:GHP_PROJECT_NUMBER = -1

    return Get-GhPEnvironment
} Export-ModuleMember -Function Clear-GhPEnvironment

function Test-GhPEnvironment{
    [CmdletBinding()]
    [Alias("tghpe")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ProjectTitle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][int]$ProjectNumber,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Owner
    )
    
    return  ($env:GHP_OWNER -eq $Owner)-and ($env:GHP_PROJECT_TITLE -eq $ProjectTitle)-and ($env:GHP_PROJECT_NUMBER -eq $ProjectNumber)
} Export-ModuleMember -Function Test-GhPEnvironment -Alias tghpe

# Private functions

function Resolve-GhEnvironmentOwner {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][Hashtable]$Environment
    )

    if($Owner){
        return $Owner
    }

    if($Environment.Owner -ne "null"){
        return $Environment.Owner
    }

    "No Owner found in Environment" | Write-Error

    return $null
}

function Resolve-GhEnvironmentProjectNumber {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter()][Hashtable]$Environment,
        [Parameter()][switch]$Force
    )

    [int]$ProjectNumber = -1

    if(($ProjectTitle -eq $Environment.ProjectTitle) -and ($Owner -eq $Environment.Owner)){
        "ProjectNumber found in Environment" | Write-Information
        $ProjectNumber = $Environment.ProjectNumber
    }

    if($Force -or ($ProjectNumber -eq -1)){
  
        "ProjectNumber NOT found in environment or Forced" | Write-Information
        
        $null = Clear-GhPEnvironment

        # Call remote
        $ProjectNumber = Get-GhProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner
    }

    return $ProjectNumber
}

function Resolve-GhEnvironmentProjectTitle {
    [CmdletBinding()]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][Hashtable]$Environment
    )

    if($ProjectTitle){
        return $ProjectTitle
    }

    if($Environment.ProjectTitle -ne "null"){
        return $Environment.ProjectTitle
    }

    "No ProjectTitle found in Environment" | Write-Error

    return $null
}

function Resolve-GhPEnviroment{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("rghpe")]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter()][switch]$Force
    )

    # Get actual values from Environment
    $env = Get-GhPEnvironment

    # Look for ProjectTitle
    $ProjectTitle = Resolve-GhEnvironmentProjectTitle -ProjectTitle $ProjectTitle -Environment $env
    if(!$ProjectTitle){return $null}

    # Look for Owner
    $Owner = Resolve-GhEnvironmentOwner -Owner $Owner -Environment $env
    if(!$Owner){return $null}

    # Look for ProjectNumber
    $ProjectNumber = Resolve-GhEnvironmentProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner -Environment $env -Force:$Force
    if($ProjectNumber -eq -1){return $null}

    # Return value
    $ret = [PSCustomObject] @{
        Owner = $Owner
        ProjectTitle = $ProjectTitle
        ProjectNumber = $ProjectNumber
    }

    # Update cache environment
    $ret | Set-GhPEnvironment

    return $ret

} Export-ModuleMember -Function Resolve-GhPEnviroment -Alias rghpe