Set-MyInvokeCommandAlias -Alias FindProject -Command 'Invoke-FindProject -Owner {owner} -Pattern "{pattern}" -firstProject {firstProject} -afterProject "{afterProject}"'

function Find-Project{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$Pattern
    )

    $params = @{
        owner = $Owner
        pattern = $Pattern
        firstProject = 100
        afterProject = $null
    }

    $result = Invoke-MyCommand -Command FindProject -Parameters $params

    $projects = $result.data.organization.projectsV2.nodes

    if(-not $projects){
        "Error finding projects for owner [$Owner] with pattern [$Pattern]" | Write-MyError
        return $null
    }

    "Verbose found [$($projects.Count)] projects for owner [$Owner] with pattern [$Pattern]" | Write-MyVerbose

    return $projects

} Export-ModuleMember -Function Find-Project