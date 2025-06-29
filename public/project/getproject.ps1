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
        $result = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
        if ( ! $result) { return }
    }

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    if($SkipItems){
        $prj.Items = @()
    }

    return $prj
} Export-ModuleMember -Function Get-Project

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
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
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