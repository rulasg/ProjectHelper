
Set-MyInvokeCommandAlias -Alias updateProjectV2 -Command 'Invoke-UpdateProjectV2 -ProjectId {projectid} -ReadMeBase64 {readmebase64}'

function Edit-Project {
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$Readme
    )

    $owner,$projectnumber = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    $db = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    $projectId = $db.ProjectId

    $params = @{
        projectid = $projectId
        readmebase64 = $Readme | ConvertTo-Base64
    }

    $result = Invoke-MyCommand -Command "updateProjectV2" -Parameters $params

    if($result.errors){
        throw "Failed to update project readme: $($result.errors | ConvertTo-Json -Depth 10)"
    }

    if(-Not $result.data.updateProjectV2.projectV2.readme -eq $Readme){
        throw "No project data returned from updateProjectV2"
    }

    $db.readme = $Readme
    $db.config = Get-ProjectConfigFromReadme -Readme $Readme

    Save-ProjectDatabaseSafe -Database $db

    return $true
} Export-ModuleMember -Function Edit-Project
