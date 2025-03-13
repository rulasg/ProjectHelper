function Mock_GetProject_Octodemop_625{

    $owner = "octodemo"
    $projectNumber = "625"

    $params = @{

        Command = "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber"
        Filename = "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.2.json"
    }

    # MockCallJson -Command "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectnumber" -Filename "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.2.json"
    MockCallJson @params

}

function Mock_GetProject_Octodemop_625_626_Sync{
    $owner = "octodemo"
    "625","626" | ForEach-Object {
        $projectNumber = $_
        $params = @{
            Command = "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber"
            Filename = "invoke-GitHubOrgProjectWithFields-$owner-$projectnumber.syncprj.json"
        }
        MockCallJson @params
    }
}