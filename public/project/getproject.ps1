function Get-Project {
    [CmdletBinding()]
    [Alias("gprj","getp")]
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
} Export-ModuleMember -Function Get-Project -Alias gprj,"getp"

function Show-Project {
    [CmdletBinding()]
    [Alias("shp")]
    param(
        [Parameter(Position=0)][string]$Owner,
        [Parameter(Position=1)][string]$ProjectNumber,
        [Parameter()][Alias("C")][switch]$NotClearScreen,
        [Parameter()][switch]$Force
    )

        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

        $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

        $activeItems = Get-ProjectItems -Owner $Owner -ProjectNumber $ProjectNumber

        # Clear screen before showing if requested
        if(-not $NotClearScreen){
            Clear-MyHost
        }
        # Before all
        addJumpLine -message "Header Start"

        # Header
        "[" | write -Color Yellow
        $p.owner | write -Color DarkCyan
        addSpace
        $p.number | write -Color DarkMagenta -Prefix "#"
        "]" | write -Color Yellow
        addSpace
        """" | write -Color Yellow
        $p.title | write -Color DarkGreen
        """" | write -Color Yellow

        addJumpLine -message "Header End"

        # URL
        $p.url | write -Color White
        addJumpLine -message "End Url"
        
        # Status
        addJumpLine -message "Start Status"
        $status = $p.status -eq "closed" ? "CLOSED" : "OPEN" ; $status | write -BetweenSquareBrackets -Color $(getStateColor $status)
        addspace
        $visibility = $p.public -eq $true ? "PUBLIC" : "PRIVATE" ; $visibility | write -BetweenSquareBrackets -Color $(getVisibilityColor $visibility)
        addJumpLine -message "End Status"
        
        # Content
        addJumpLine -message "Start Content"
        "Items:" | write -Color DarkGray ; $activeItems.count | write -Color DarkYellow ; "/" | write -Color Yellow ; $p.totalCount_items | write -Color Gray
        addSpace
        "Fields:" | write -Color DarkGray ; $p.totalCount_fields | write -Color DarkGreen
        addSpace
        "Staged:" | write -Color DarkGray ; $p.staged.count | write -Color Red
        addJumpLine -message "End Content"

        # Show ReadMe and Description
        "Short Description" | writeHeader1
        $p.shortDescription | write -Color White
        addJumpLine -message "End Short Description"
        "ReadMe" | writeHeader1
        $p.readme | write -Color White
        addJumpLine -message "End ReadMe"
        
        addJumpLine -message "End"
        
        # Total Items count
        #  $p.items.count

        # Total Fields count
        # $p.fields.count

        return $prj
} Export-ModuleMember -Function Show-Project -Alias shp

function Update-Project{
    [CmdletBinding()]
    [Alias("up")]
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
        $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query "$query"
        
        Set-EnvProjectLastUpdate_Today -Owner $Owner -ProjectNumber $ProjectNumber
    }
    else{
        "Performing PARTIAL update for $Owner/$ProjectNumber with query [$Query]" | Write-MyDebug -Section "Update-Project"
        $ret = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems -Query $Query
    }

    return $ret
} Export-ModuleMember -Function Update-Project -Alias up

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
    [Alias("op")]
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

} Export-ModuleMember -Function Open-Project -Alias op
