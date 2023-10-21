
function ProjectHelperTest_GHPEnvironment_Resolve{

    $ProjectTitle = "PublicProject"
    $owner = "owner1"

    $expressionPattern_Project_List = 'gh project list --owner "{0}" --limit 1000 --format json'

     Set-DevUser1

    Clear-ProjectEnvironment

    $result = Resolve-ProjectEnviroment -ProjectTitle $ProjectTitle -Owner $owner  @InfoParameters -WhatIf

    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Project_List -f $owner)
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 666

    # Second call with ProjectNumber cached on environment
    $result = Resolve-ProjectEnviroment -ProjectTitle $ProjectTitle -Owner $owner  @InfoParameters -WhatIf

    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber found in Environment'
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 666

    # With Force
    $result = Resolve-ProjectEnviroment -ProjectTitle $ProjectTitle -Owner $owner -Force  @InfoParameters -WhatIf
    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber found in Environment'
    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Project_List -f $owner)
    Assert-AreEqual -Expected $result.ProjectNumber -Presented 666
}