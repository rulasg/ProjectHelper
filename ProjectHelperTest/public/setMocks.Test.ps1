
function ProjectHelperTest_MockCommandWithFileData_Set_Command{

    $mockspath = Get-MockFilePath
    $mockPath = $mockspath | Join-Path -ChildPath 'version.txt' | Convert-Path
    $cl = Get-CommandList
    
    $result = Set-MockCommand -CommandName 'Version'

    Assert-IsNull -Object $result
    Assert-AreEqual -Expected "Get-Content -Path $mockPath" -Presented $cl.Version.Command
    Assert-IsFalse -Condition $cl.Version.IsJson
}

function ProjectHelperTest_MockCommandWithFileData_Set_FileName{

    $kk = New-TestingFile -Path $(Get-MockFilePath) -Name kk -Content 'fake content' -PassThru

    $mockspath = Get-MockFilePath
    $mockPath = $mockspath | Join-Path -ChildPath 'kk' | Convert-Path
    $cl = Get-CommandList

    $result = Set-MockCommand -CommandName 'Version' -FileName kk

    Assert-IsNull -Object $result
    Assert-AreEqual -Expected "Get-Content -Path $mockPath" -Presented $cl.Version.Command
    Assert-IsFalse -Condition $cl.Version.IsJson

    $kk | Remove-Item
}