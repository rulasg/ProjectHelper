
function ProjectHelperTest_GHP_AddGHPDraft_Parameters_Success{

    # Testing parameters input. All calls to New-GhPItem will fail on checking for ProjectNumber in Environment
    $owner ="owner-Name"
    $projectName = "projectName"

    Clear-GhPEnvironment

    $result = New-GhPItem -Title "title text" -Body "body text" -ProjectTitle $projectName -Owner $owner @InfoParameters -WhatIf
    Assert-IsNull -Object $result
    Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

    
    $result = New-GhPItem -ProjectTitle $projectName -Owner $owner "title text" "body text" @ErrorParameters -WhatIf
    Assert-IsNull -Object $result
    Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

    $result = New-GhPItem "title text" "body text" -ProjectTitle $projectName -Owner $owner @ErrorParameters -WhatIf
    Assert-IsNull -Object $result
    Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

}

$expressionPattern_Project_List = 'gh project list --owner "{0}" --limit 1000 --format json'

function ProjectHelperTest_GHP_SetGhPEnvironment_Success{

    Clear-GhPEnvironment
    
    $result = Set-GhPEnvironment -Owner "owner2" -ProjectTitle "title2" -ProjectNumber 66699 -Passthru
    
    $result = Get-GhPEnvironment
    
    Assert-AreEqual -Presented $result.Owner -Expected "owner2"
    Assert-AreEqual -Presented $result.ProjectTitle -Expected "title2"
    Assert-AreEqual -Presented $result.ProjectNumber -Expected 66699
}

function ProjectHelperTest_GHP_SetGhPEnvironment_Pipe{
    
    Clear-GhPEnvironment
    
    $values = [PSCustomObject]@{
        Owner = "owner1" 
        ProjectTitle = "title1" 
        ProjectNumber = 666
    }
    
    $result = $values | Set-GhPEnvironment -Passthru
    
    Assert-AreEqual -Presented $result.Owner -Expected "owner1"
    Assert-AreEqual -Presented $result.ProjectTitle -Expected "title1"
    Assert-AreEqual -Presented $result.ProjectNumber -Expected 666
}

$expressionPattern_Item_Create = "gh project item-create {0} --owner `"{1}`" --title `"{2}`" --body `"{3}`""

function ProjectHelperTest_GHP_GHPItem_Add_Manual_With_Environment{

    # Testing parameters input. All calls to New-GhPItem will fail on checking for ProjectNumber in Environment
    # "gh project item-create 60 --owner `"solidify-internal`" --title `"title text`" --body `"body text`""
    # $expressionPattern_Item_Create = "gh project item-create {0} --owner `"{1}`" --title `"{2}`" --body `"{3}`""

    $projectNumber = 666 #1
    $owner = "solidify-internal" #2
    $title = "title text" #3
    $body = "body text" #4
    $projectTitle = "Clients Planner"

    # $expressionPattern_Project_List = "gh project list --owner {0} --limit 1000 --format json"

    Set-GhPEnvironment -Owner $owner -ProjectTitle $projectTitle -ProjectNumber $projectNumber

    # Use cached environment for parameters
    $result = New-GhPItem -Title $title -Body $body -whatif @InfoParameters
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Item_Create -f $projectNumber, $owner, $title, $body)
    Assert-IsNull -Object $result
    
    # Use parameters. Will refresh environment
    $result = New-GhPItem -ProjectTitle "projectName" -Owner "ownerName" $title $body -Whatif @InfoParameters
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Project_List -f "ownerName")
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Item_Create -f 666, "ownerName", $title, $body)
    Assert-IsNull -Object $result

    # Env Cached
    $result = New-GhPItem $title $body -ProjectTitle "projectName" -Owner "ownerName" -Whatif @InfoParameters
    Assert-Contains -Presented $infoVar.MessageData -Expected "ProjectNumber found in Environment"
    Assert-Contains -Presented $infoVar.MessageData -Expected ($expressionPattern_Item_Create -f 666, "ownerName", $title, $body)
    Assert-IsNull -Object $result

}

function ProjectHelperTest_GHP_GHPItem_Add_Manual_Success{

    $owner = "owner2"
    $projectTitle = "Clients Planner"
    $projectNumber = 666
    $itemTitle = "title text"
    $itemBody = "body text"

    $expectedItemCreate = 'gh project item-create {0} --owner "{1}" --title "{2}" --body "{3}"' -f $projectNumber, $owner, $itemTitle, $itemBody

    $expresionProjectList = 'gh project list --owner "{0}" --limit 1000 --format json' -f $owner
    
    Set-DevUser2
    
    $null = Clear-GhPEnvironment

    $result = New-GhPItem -ProjectTitle $projectTitle -Owner $owner -Title $itemTitle -Body $itemBody -WhatIf @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'
    Assert-Contains -Presented $infoVar.MessageData -Expected $expresionProjectList
    Assert-Contains -Presented $infoVar.MessageData -Expected $expectedItemCreate
}

function ProjectHelperTest_GHP_GHPItems_Get_Success{
    # Need to inject gh call for testing

    Set-DevUser2

    $result = Get-GhPItems -ProjectTitle "Clients Planner" -Owner "solidify-internal" -WhatIf @InfoParameters
    Assert-IsNull -Object $result
}

function ProjectHelperTest_GHP_Projects_Success{
    Set-DevUser2

    $expressionPattern_Project_List = 'gh project list --limit 1000 --format json'
    $expressionPattern_Project_List += ' --owner "{0}"'
    $command = $expressionPattern_Project_List -f "ownername"

    $result = Get-GhProjects -Title "publi*" -Owner "ownername" -WhatIf  *>&1

    Assert-Contains -Presented $result.MessageData -Expected $command
}