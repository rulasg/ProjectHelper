function Get-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Owner,
        [Parameter(Position=1)][string]$ProjectNumber,
        [Parameter()][switch]$SkipItems,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $prj = getProjectCache -Owner $Owner -ProjectNumber $ProjectNumber

    if(-Not $prj -or $Force){
        "No cache found for $Owner/$ProjectNumber or force specified. Retrieving project from database." | Write-MyDebug -Section Get-Project

        if ($Force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)) {
            "Project not found in database or force specified. Updating project for $Owner/$ProjectNumber." | Write-MyDebug -Section Get-Project

            $result = Update-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
            
            if ( ! $result) { 
                "Failed to update project for $Owner/$ProjectNumber. Project may not exist or there was an error during update." | Write-MyError
                resetProjectCache -Owner $Owner -ProjectNumber $ProjectNumber
                return 
            }
        } else {
            "Project found in database for $Owner/$ProjectNumber. Loading project." | Write-MyDebug -Section Get-Project
        }

        $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

        setProjectCache -Owner $Owner -ProjectNumber $ProjectNumber -Project $prj

    }
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
        $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query
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

$script:ProjectsCache = @{}

function getProjectCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$Owner,
        [Parameter(Mandatory,Position = 1)][string]$ProjectNumber
    )

    $key = "$Owner-$ProjectNumber"
    $lockKey = Get-DatabaseKey $Owner $ProjectNumber "project-cachelock"

    $lock = Get-Database -Key $lockKey

    if([string]::IsNullOrWhiteSpace($lock)){
        "No cache lock found for $Owner/$ProjectNumber. Cache will be ignored." | Write-MyDebug -Section "Get-Project"
        return $null
    }

    $cache = $script:ProjectsCache[$key]

    if($lock -cne $cache.SafeId) {
        "Cache lock mismatch for $Owner/$ProjectNumber. Cache safeId [$($cache.SafeId)], lock [$lock]. Cache will be ignored." | Write-MyDebug -Section "Get-Project"
        $script:ProjectsCache.Remove($key)
        return $null
    }

    "Getting fields cache for $Owner/$ProjectNumber with lock [$lock] and cache safeId [$($cache.SafeId)]" | Write-MyDebug -Section "Get-Project"
    return $cache.List
}

function setProjectCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$Owner,
        [Parameter(Mandatory,Position = 1)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 2)][object]$Project
    )

    $key = "$Owner-$ProjectNumber"
    $lockKey = Get-DatabaseKey $Owner $ProjectNumber "project-cachelock"

    $safeId = [Guid]::NewGuid().ToString()

    "Setting project cache for $Owner/$ProjectNumber with safeId [$safeId]" | Write-MyDebug -Section "Get-Project"

    # Save safeId to project-lock
    Save-Database -Database $safeId -Key $lockKey

     # Set lock in database to prevent concurrent updates
    $script:ProjectsCache[$key] = @{
        List = $Project
        SafeId = $safeId
    }
}

function resetProjectCache{
    param(
        [Parameter(Mandatory,Position = 0)][string]$Owner,
        [Parameter(Mandatory,Position = 1)][string]$ProjectNumber
    )

    "Resetting project cache for $Owner/$ProjectNumber" | Write-MyDebug -Section "Get-Project"

    $key = "$Owner-$ProjectNumber"
    $script:ProjectsCache.Remove($key)
}
