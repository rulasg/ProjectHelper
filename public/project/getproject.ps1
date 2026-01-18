function Get-Project {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Get-Project"
    }

    if ($Force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)) {
        $result = Update-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
        if ( ! $result) { return }
    }

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    if($SkipItems){
        $prj.Items = @()
    }

    return $prj
} Export-ModuleMember -Function Get-Project

function Update-Project{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [parameter()][string]$Query,
        [Parameter()][switch]$SkipItems
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Update-Project"
    }

    $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query

    # Check if we did a full projectupdate
    if([string]::IsNullOrEmpty($Query)){
        # Reset recent to today
        Set-EnvItem_Last_RecentUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }

    return $ret
} Export-ModuleMember -Function Update-Project

function Get-ProjectId {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Get-ProjectId"
    }

    # Get project id
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems

    $id = $project.ProjectId

    return $id
} Export-ModuleMember -Function Get-ProjectId

function Open-Project{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        throw "Owner and ProjectNumber are required on Open-Project"
    }

    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -skipItems
    if (-not $project) {
        throw "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]"
    }
    $projectUrl = $project.url

    # Open the URL based on the operating system
    if ($IsWindows -or $env:OS -match "Windows") {
        Start-Process $projectUrl
    }
    elseif ($IsMacOS) {
        Start-Process "open" -ArgumentList $projectUrl
    }
    elseif ($IsLinux) {
        Start-Process "xdg-open" -ArgumentList $projectUrl
    }
    else {
        Write-Warning "Unknown operating system. Cannot open URL automatically."
        Write-Host "URL: $projectUrl"
    }

} Export-ModuleMember -Function Open-Project

function Set-Project {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName, Position = 1)][string]$ProjectNumber
    )

    process {

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
            throw "Owner and ProjectNumber are required on Open-Project"
        }
    }

} Export-ModuleMember -Function Set-Project