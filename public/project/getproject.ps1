Set-MyInvokeCommandAlias -Alias GitHubOrgProject -Command 'Invoke-GitHubOrgProjectWithFields -Owner {owner} -ProjectNumber {projectnumber} '

function Get-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { 
        throw "Owner and ProjectNumber are required on Get-Project"
    }

    if ($force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)) {
        $result = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        if ( ! $result) { return }
    }

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    return $prj
} Export-ModuleMember -Function Get-Project

function Get-ProjectId {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) { 
        throw "Owner and ProjectNumber are required on Get-ProjectId"
    }

    if ($force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)) {
        $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }
        $response = Invoke-MyCommand -Command GitHubOrgProject -Parameters $params

        $id = $response.data.organization.projectV2.id

    } else {
        $response = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        $id = $response.ProjectId
    }

    return $id
} Export-ModuleMember -Function Get-ProjectId