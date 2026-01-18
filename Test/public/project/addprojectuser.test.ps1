function Test_AddProjectUser_SUCCESS_SingleUser{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # Enable-invokeCommandAliasModule
    # Invoke-UpdateProjectV2Collaborators -ProjectId PVT_kwDOAlIw4c4BCe3V -collaborators "MDQ6VXNlcjY4ODQ0MDg=" -Role "WRITER"


    $p =Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems

    $u = Get-Mock_Users

    $userId1 = $u.u1.id ; $userName1 = $u.u1.name
    $role ="WRITER"

    $fileName = "invoke-UpdateProjectV2Collaborators-$userId1.json"

    MockCallJson -Command "Invoke-GetUser -Handle $userName1" -File $u.u1.file
    MockCallJson -Command "Invoke-UpdateProjectV2Collaborators -ProjectId $projectId -collaborators ""$userId1"" -Role ""$role""" -File $fileName
    
    $result = Add-ProjectUser -Owner $owner -ProjectNumber $projectNumber -Handle $userName1 -Role $role

    Assert-IsTrue $result
}

function Test_AddProjectUser_SUCCESS_MultipleUser{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p =Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems

    $u = Get-Mock_Users

    $userId1 = $u.u1.id ; $userName1 = $u.u1.name
    $userId2 = $u.u2.id ; $userName2 = $u.u2.name
    $userNames = "$userName1","$userName2"
    $usersIds ="$userId1 $userId2"
    $role ="WRITER"
    $fileName = "invoke-UpdateProjectV2Collaborators-$userId1-$userId2.json"

    MockCallJson -Command "Invoke-GetUser -Handle $userName1" -File $u.u1.file
    MockCallJson -Command "Invoke-GetUser -Handle $userName2" -File $u.u2.file
    MockCallJson -Command "Invoke-UpdateProjectV2Collaborators -ProjectId $projectId -collaborators ""$usersIds"" -Role ""$role""" -File $fileName
    
    $result = $userNames | Add-ProjectUser -Owner $owner -ProjectNumber $projectNumber -Role $role

    Assert-IsTrue $result
}