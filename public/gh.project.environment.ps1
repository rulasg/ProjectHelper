
<#
.Synopsis 
GitHub Project functions that shows Enviroment variables used on GH Projects commands
#>
function Get-EnvironmentProject{
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

} Export-ModuleMember -Function Get-EnvironmentProject -Alias gghpe

<#
.Synopsis
Sets environment variables for GH Projects commands
#>
function Set-ProjectEnvironment{
    [CmdletBinding()]
    [Alias("sghpe")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ProjectTitle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][int]$ProjectNumber,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Owner,
        #passthrough
        [Parameter()][switch]$PassThru
    )

    '$env:GHP_OWNER = ' + $Owner | Write-Verbose
     $env:GHP_OWNER = $Owner

     '$env:GHP_PROJECT_TITLE = ' + $ProjectTitle | Write-Verbose
     $env:GHP_PROJECT_TITLE = $ProjectTitle

     '$env:GHP_PROJECT_NUMBER = ' + $ProjectNumber | Write-Verbose
     $env:GHP_PROJECT_NUMBER = $ProjectNumber

    if($PassThru){
        return Get-EnvironmentProject
    }
} Export-ModuleMember -Function Set-ProjectEnvironment -Alias sghpe

<#
.Synopsis
Clears environment variables for GH Projects commands
#>
function Clear-ProjectEnvironment{
    [CmdletBinding()]
    param(
    )

    # $env:GHP_OWNER = "null"
    # $env:GHP_PROJECT_TITLE = "null"
    # $env:GHP_PROJECT_NUMBER = -1
    Set-ProjectEnvironment -ProjectTitle "null" -ProjectNumber -1 -Owner "null"

    return Get-EnvironmentProject
} Export-ModuleMember -Function Clear-ProjectEnvironment

function Test-ProjectEnvironment{
    [CmdletBinding()]
    [Alias("tghpe")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ProjectTitle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][int]$ProjectNumber,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Owner
    )
    $ret = ($env:GHP_OWNER -eq $Owner)-and ($env:GHP_PROJECT_TITLE -eq $ProjectTitle)-and ($env:GHP_PROJECT_NUMBER -eq $ProjectNumber)

    # traceparametrs and return
    'Test-ProjectEnvironment -ProjectTitle {0} -ProjectNumber {1} -Owner {2} = {3}' -f $ProjectTitle, $ProjectNumber, $Owner, $ret | Write-Verbose

    return  $ret
} Export-ModuleMember -Function Test-ProjectEnvironment -Alias tghpe

# Private functions

function Resolve-EnvironmentProjectOwner {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][Hashtable]$Environment
    )

    if($Owner){
        "Using parameter Owner" | Write-Information
        return $Owner
    }

    if($Environment.Owner -ne "null"){
        "Owner found in Environment" | Write-Information
        return $Environment.Owner
    }

    "No Owner found in Environment" | Write-Error

    return $null
}

function Resolve-EnvironmentProjectNumber {
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
        
        $null = Clear-ProjectEnvironment

        # Call remote
        $ProjectNumber = Get-ProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner
    }

    return $ProjectNumber
}

function Resolve-EnvironmentProjectTitle {
    [CmdletBinding()]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][Hashtable]$Environment
    )

    if($ProjectTitle){
        "Using parameter ProjectTitle" | Write-Information
        "ProjectTitle return : $ProjectTitle" | Write-Information
        return $ProjectTitle
    }

    if($Environment.ProjectTitle -ne "null"){
        "ProjectTitle found in Environment" | Write-Information
        "ProjectTitle return : $($Environment.ProjectTitle)" | Write-Information

        return $Environment.ProjectTitle
    }

    "No ProjectTitle found in Environment" | Write-Error
    "ProjectTitle return : null" | Write-Information

    return $null
}

function Resolve-EnvironmentProject{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("rghpe")]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter()][switch]$Force
    )

    # Get actual values from Environment
    $env = Get-EnvironmentProject

    # Look for ProjectTitle
    $ProjectTitle = Resolve-EnvironmentProjectTitle -ProjectTitle $ProjectTitle -Environment $env
    if(!$ProjectTitle){return $null}

    # Look for Owner
    $Owner = Resolve-EnvironmentProjectOwner -Owner $Owner -Environment $env
    if(!$Owner){return $null}

    # Look for ProjectNumber
    $ProjectNumber = Resolve-EnvironmentProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner -Environment $env -Force:$Force
    if($ProjectNumber -eq -1){return $null}

    # Return value
    $ret = [PSCustomObject] @{
        Owner = $Owner
        ProjectTitle = $ProjectTitle
        ProjectNumber = $ProjectNumber
    }

    # Update cache environment
    $ret | Set-ProjectEnvironment

    return $ret

} Export-ModuleMember -Function Resolve-EnvironmentProject -Alias rghpe