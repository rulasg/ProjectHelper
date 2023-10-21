

function Resolve-GhIEnvironmentRepo {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Repo
    )

    # $env = Get-GhIEnvironment

    if($Repo){
        return $Repo
    }

    # TODO: define where to cache the repo
    # if($env.GHI_REPO -ne "null"){
    #     return $env.GHI_REPO
    # }

    "No Repo found in Environment" | Write-Error

    return $null
}