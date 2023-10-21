
function ProjectHelperTest_MockCommandWithFileData_Set_Command{

    $result = Set-MockCommandWithFileData -CommandName 'Version'

    Assert-IsNull -Object $result

    Assert-IsTrue -Condition $commandlist.Version.StartsWith("Get-Content -Path")
    Assert-IsTrue -Condition $CommandList.Version.EndsWith('version.txt')

    Assert-ItemExist -Path $commandlist.Version.Substring(18)
}

function ProjectHelperTest_MockCommandWithFileData_Set_FileName{

    $kk = New-TestingFile -Path $(Get-MockFilePath) -Name kk -Content 'fake content' -PassThru
    $result = Set-MockCommandWithFileData -CommandName 'Version' -FileName 'kk'

    Assert-IsNull -Object $result

    Assert-IsTrue -Condition $commandlist.Version.StartsWith("Get-Content -Path")
    Assert-IsTrue -Condition $CommandList.Version.EndsWith('kk')

    Assert-ItemExist -Path $commandlist.Version.Substring(18)

    $kk | Remove-Item
}