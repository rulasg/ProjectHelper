function ProjectHelperTest_GetGitHubProjectFields{

    Enable-InvokeCommandAlias -Tag ProjectHelperModule

    $owner = "solidifydemo" ; $projectnumber = 164

    $fileName = $MOCK_PATH | Join-Path -ChildPath 'orgprojectwithfields.json'
    $content = Get-Content -Path $fileName | Out-String
    
    Set-Mock_GitHubProjectFields -Content $content

    $result = _GitHubProjectFields -Owner $owner -Project $projectnumber -Token $env:GITHUB_TOKEN

    Assert-AreEqual -Expected 164 -Presented $result.data.organization.projectv2.number
    Assert-AreEqual -Expected "PVT_kwDOBCrGTM4ActQa" -Presented $result.data.organization.projectv2.id
    Assert-Count -Expected 12 -Presented $result.data.organization.projectv2.items.nodes
    Assert-Count -Expected 18 -Presented $result.data.organization.projectv2.fields.nodes
}