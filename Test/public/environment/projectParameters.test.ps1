function Test_SetProjectParameters_SUCCESS{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number ; $projectTitle = $p.title
    MockCall_GetProject $p
    $dbPath = Get-Mock_DatabaseRootPath

    # Act
    Set-ProjectParameters -Owner $owner -ProjectNumber $projectNumber

    $v = @{
        Owner = @{value =$owner ; file = $($dbPath | Join-Path -Child "EnvironmentCache_Owner.json")}
        ProjectNumber = @{value =$projectNumber ; file = $($dbPath | Join-Path -Child "EnvironmentCache_ProjectNumber.json")}
        ProjectTitle = @{value =$projectTitle ; file = $($dbPath | Join-Path -Child "EnvironmentCache_ProjectTitle.json")}
    }

    $v.keys | ForEach-Object {
        $key = $_
        Assert-AreEqual -Expected $v[$key].value -Presented (Get-Content -Path $v[$key].file | ConvertFrom-Json)
    }
}