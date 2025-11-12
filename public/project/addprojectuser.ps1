Set-MyInvokeCommandAlias -Alias "updateProjectV2Collaborators" -Command 'Invoke-UpdateProjectV2Collaborators -ProjectId {projectid} -collaborators "{collaboratorsIds}" -Role "{role}"'

function Add-ProjectUser {
    [CmdletBinding()]
        param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory,ValueFromPipeline)][string]$Handle,
        [Parameter()][string]$Role ="WRITER"

    )

    begin{

        ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
        if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)) {
            throw "Owner and ProjectNumber are required on Get-Project"
        }
        
        $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems
        
        $projectId = $project.ProjectId

        $userIds = @()

    }

    process{
        
        $user = Get-User -Handle $Handle
        $userId = $user.Id

        if([string]::IsNullOrWhiteSpace($userId)){
            Write-Error "No user found for handle [$Handle]"
        }

        $userIds += $userId
    }

    end{

        $userIdsString = $userIds -join " "

        if([string]::IsNullOrWhiteSpace($userIdsString)){
            Write-Error "No users found"
            return $false
        }

        $response = Invoke-MyCommand -Command "updateProjectV2Collaborators" -Parameters @{
            projectid = $projectId
            role = $Role
            collaboratorsIds = $userIdsString
        }

        # Check reply data to confirm users were added
        if($response.data.updateProjectV2Collaborators.collaborators.totalCount -ne $userIds.Count){
            Write-Error "Not all users were added to the project"
            return $false
        }

        return $true
    }










} Export-ModuleMember -Function Add-ProjectUser
