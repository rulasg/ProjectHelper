
function ProjectHelperTest_GHPEnvironment_Resolve{

    $ProjectTitle = "Public Project"
    $owner = "rulasg"

    Set-MockCommand -CommandName 'Project_List_Owner'

    Clear-ProjectEnvironment

    $result = Resolve-EnvironmentProject -ProjectTitle $ProjectTitle -Owner $owner  @InfoParameters

    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 11
    Assert-AreEqual -Expected $result.ProjectTitle -Presented $ProjectTitle
    Assert-AreEqual -Expected $result.Owner -Presented rulasg

    # Second call with ProjectNumber cached on environment
    $result = Resolve-EnvironmentProject -ProjectTitle $ProjectTitle -Owner $owner  @InfoParameters

    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber found in Environment'
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 11

    # With Force
    $result = Resolve-EnvironmentProject -ProjectTitle $ProjectTitle -Owner $owner -Force  @InfoParameters
    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber found in Environment'
    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 11
}