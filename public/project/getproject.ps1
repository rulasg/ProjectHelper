function Get-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
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
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
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