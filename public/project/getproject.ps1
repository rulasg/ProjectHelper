function Get-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Owner,
        [Parameter(Position=1)][string]$ProjectNumber,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "Getting project for $Owner/$ProjectNumber with SkipItems=$SkipItems and Force=$Force >>>" | Write-MyDebug -Section "Get-Project"

    if ($Force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)) {
        "Project not found in database or force specified. Updating project for $Owner/$ProjectNumber." | Write-MyDebug -Section Get-Project

        $result = Update-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Force:$Force
        
        if ( ! $result) {
            "Failed to update project for $Owner/$ProjectNumber. Project may not exist or there was an error during update." | Write-MyError
            return
        }
    } else {
        "Project found in database for $Owner/$ProjectNumber. Calling to retreive." | Write-MyDebug -Section Get-Project
    }

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    "Getting project for $Owner/$ProjectNumber with SkipItems=$SkipItems and Force=$Force <<< $($prj.safeId)" | Write-MyDebug -Section "Get-Project"

    return $prj
} Export-ModuleMember -Function Get-Project

function Update-Project{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [parameter()][string]$Query,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    if([string]::IsNullOrEmpty($Query)){

        # Update just the items that were modified unless -Force
        if(! $Force){
            "Performing INCREMENTAL update for $Owner/$ProjectNumber" | Write-MyDebug -Section "Update-Project"
            $recentQuery = Get-UpdateRecentQuery -Owner $Owner -ProjectNumber $ProjectNumber

            $query = $recentQuery
        } else {
            "Performing FULL update for $Owner/$ProjectNumber" | Write-MyDebug -Section "Update-Project"
        }
        $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
        Set-EnvProjectLastUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }
    else{
        "Performing PARTIAL update for $Owner/$ProjectNumber with query [$Query]" | Write-MyDebug -Section "Update-Project"
        $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query
    }

    return $ret
} Export-ModuleMember -Function Update-Project

function Get-ProjectId {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    # Get project id
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems

    $id = $project.ProjectId

    return $id
} Export-ModuleMember -Function Get-ProjectId

function Open-Project{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][int]$ProjectNumber,
        [Parameter(ValueFromPipelineByPropertyName)][string]$View
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -skipItems
    if (-not $project) {
        throw "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]"
    }
    
    $builder = [UriBuilder]$project.url

    if (-Not [string]::IsNullOrEmpty($View)) {
        $builder.Path = "$($builder.Path)/views/$View"
    }

    $projectUrl = $builder.Uri

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
