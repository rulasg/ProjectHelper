Set-MyInvokeCommandAlias -Alias FindProject -Command 'Invoke-FindProject -Owner {owner} -Pattern "{pattern}" -firstProject {firstProject} -afterProject "{afterProject}"'
<#
.SYNOPSIS
    Find a project by name pattern
.DESCRIPTION
    Find a project using a search pattern used on GitHub UI.
.EXAMPLE
    Find-Project -owner githubcustomers -pattern creator:rulasg
    Find all projects in the organization githubcustomers created by user rulasg
.EXAMPLE
    Find-Project -owner octodemo -pattern "development"
    Find all projects in the organization octodemo with "development" in the title of the project

.NOTES
    Reference: https://docs.github.com/en/issues/planning-and-tracking-with-projects/finding-your-projects#syntax-for-filtering-a-list-of-projects
#>
function Find-Project{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$Pattern
    )

    # Seaarch syntax: https://docs.github.com/en/issues/planning-and-tracking-with-projects/finding-your-projects#syntax-for-filtering-a-list-of-projects


    $params = @{
        owner = $Owner
        pattern = $Pattern
        firstProject = 100
        afterProject = $null
    }

    $result = Invoke-MyCommand -Command FindProject -Parameters $params

    $projects = $result.data.organization.projectsV2.nodes

    if($null -eq $projects){
        "Error finding projects for owner [$Owner] with pattern [$Pattern]" | Write-MyError
        return $null
    }

    "[$($projects.Count)] projects found" | Write-MyVerbose
    return $projects

} Export-ModuleMember -Function Find-Project