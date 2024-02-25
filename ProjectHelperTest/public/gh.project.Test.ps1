
# function ProjectHelperTest_GHP_AddGHPDraft_Parameters_Success{

#     # Testing parameters input. All calls to New-ProjectItem will fail on checking for ProjectNumber in Environment
#     $owner ="owner-Name"
#     $projectName = "projectName"

#     Clear-ProjectEnvironment

#     $result = New-ProjectItem -Title "title text" -Body "body text" -ProjectTitle $projectName -Owner $owner @InfoParameters -WhatIf
#     Assert-IsNull -Object $result
#     Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

    
#     $result = New-ProjectItem -ProjectTitle $projectName -Owner $owner "title text" "body text" @ErrorParameters -WhatIf
#     Assert-IsNull -Object $result
#     Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

#     $result = New-ProjectItem "title text" "body text" -ProjectTitle $projectName -Owner $owner @ErrorParameters -WhatIf
#     Assert-IsNull -Object $result
#     Assert-Contains -Expected "ProjectNumber NOT found in environment or Forced" -Presented $infoVar.MessageData

# }

# $expressionPattern_Project_List = 'gh project list --owner "{0}" --limit 1000 --format json'

# function ProjectHelperTest_GHP_SetProjectEnvironment_Success{

#     Clear-ProjectEnvironment
    
#     $result = Set-ProjectEnvironment -Owner "owner2" -ProjectTitle "title2" -ProjectNumber 66699 -Passthru
    
#     $result = Get-ProjectEnvironment
    
#     Assert-AreEqual -Presented $result.Owner -Expected "owner2"
#     Assert-AreEqual -Presented $result.ProjectTitle -Expected "title2"
#     Assert-AreEqual -Presented $result.ProjectNumber -Expected 66699
# }

# function ProjectHelperTest_GHP_SetProjectEnvironment_Pipe{
    
#     Clear-ProjectEnvironment
    
#     $values = [PSCustomObject]@{
#         Owner = "owner1" 
#         ProjectTitle = "title1" 
#         ProjectNumber = 666
#     }
    
#     $result = $values | Set-ProjectEnvironment -Passthru
    
#     Assert-AreEqual -Presented $result.Owner -Expected "owner1"
#     Assert-AreEqual -Presented $result.ProjectTitle -Expected "title1"
#     Assert-AreEqual -Presented $result.ProjectNumber -Expected 666
# }

# $expressionPattern_Item_Create = "gh project item-create {0} --owner `"{1}`" --title `"{2}`" --body `"{3}`""

# function ProjectHelperTest_ProjectItem_New__With_Environment{

#     # Testing parameters input. All calls to New-ProjectItem will fail on checking for ProjectNumber in Environment
#     # "gh project item-create 60 --owner `"owner2`" --title `"title text`" --body `"body text`""
#     # $expressionPattern_Item_Create = "gh project item-create {0} --owner `"{1}`" --title `"{2}`" --body `"{3}`""

#     $projectNumber = 11
#     $owner = "rulasg"
#     $projectTitle = "Public Project"

#     Set-MockCommand -CommandName Project_List_Owner 
#     Set-MockCommand -CommandName Project_Item_Create

#     Set-ProjectEnvironment -Owner $owner -ProjectTitle $projectTitle -ProjectNumber $projectNumber

#     # Use cached environment for parameters
#     $result = New-ProjectItem -Title "title of item" -Body "Body of item" @InfoParameters

#     Assert-Contains -Presented $infoVar.MessageData -Expected "ProjectNumber found in Environment"
#     Assert-Contains -Presented $infoVar.MessageData -Expected "ProjectTitle found in Environment"
#     Assert-Contains -Presented $infoVar.MessageData -Expected "Owner found in Environment"
#     # From Mock
#     Assert-AreEqual -Expected "Title text" -Presented $result.title
#     Assert-AreEqual -Expected "Body text to be used" -Presented $result.body
#     Assert-AreEqual -Expected 'DraftIssue' -presented $result.type

#     $result = New-ProjectItem -ProjectTitle $projectTitle -Owner $owner -Title "Title text" -Body "Body text to be used" @InfoParameters

#     Assert-Contains -Presented $infoVar.MessageData -Expected "ProjectNumber found in Environment"
#     Assert-Contains -Presented $infoVar.MessageData -Expected "Using parameter ProjectTitle"
#     Assert-Contains -Presented $infoVar.MessageData -Expected "Using parameter Owner"
#     # From Mock
#     Assert-AreEqual -Expected "Title text" -Presented $result.title
#     Assert-AreEqual -Expected "Body text to be used" -Presented $result.body
#     Assert-AreEqual -Expected 'DraftIssue' -presented $result.type
# }

# function ProjectHelperTest_ProjectItem_New_Success{

#     $owner = "owner2"
#     $projectTitle = "Clients Planner"
#     # $projectNumber = 666
#     # $itemTitle = "title text"
#     # $itemBody = "body text"

#     # $expectedItemCreate = 'gh project item-create {0} --owner "{1}" --title "{2}" --body "{3}"' -f $projectNumber, $owner, $itemTitle, $itemBody
#     # $expresionProjectList = 'gh project list --owner "{0}" --limit 1000 --format json' -f $owner
#     Set-MockCommand -CommandName Project_List_Owner 
#     Set-MockCommand -CommandName Project_Item_Create

#     $null = Clear-ProjectEnvironment

#     $result = New-ProjectItem -ProjectTitle $projectTitle -Owner $owner -Title "Title text" -Body "Body text to be used" @InfoParameters
    
#     Assert-IsNotNull -Object $result
#     Assert-Contains -Presented $infoVar.MessageData -Expected 'ProjectNumber NOT found in environment or Forced'

#     # From Mock
#     Assert-AreEqual -Expected "Title text" -Presented $result.title
#     Assert-AreEqual -Expected "Body text to be used" -Presented $result.body
#     Assert-AreEqual -Expected 'DraftIssue' -presented $result.type
# }

# function ProjectHelperTest_GHP_GHPItems_Get_Success{
#     # Need to inject gh call for testing

#     Set-MockCommand -CommandName 'Project_Item_List'
#     Set-MockCommand -CommandName 'Project_List_Owner'

#     $result = Get-ProjectItems -ProjectTitle "Public Project" -Owner "owner2"

#     Assert-Count -Expected 3 -Presented $result.items
#     Assert-AreEqual -Expected 3 -Presented $result.totalCount
#     Assert-Contains -Presented $result.items.title -Expected "Item 1 - title"
#     Assert-Contains -Presented $result.items.title -Expected "item2 title2"
#     Assert-Contains -Presented $result.items.title -Expected "Item Title"
# }

# function ProjectHelperTest_GHP_Projects_Success{

#     # $expressionPattern_Project_List = 'gh project list --limit 1000 --format json'
#     # $expressionPattern_Project_List += ' --owner {0}'
#     # $command = $expressionPattern_Project_List -f "ownername"

#     Set-MockCommand -CommandName 'Project_List_Owner' -FileName 'project_list.json'

#     $result = Get-ProjectList -Title "*Project" -Owner dumyowner

#     Assert-Count -Expected 1 -Presented $result
#     Assert-Contains -Presented $result.title -Expected "Public Project"
#     Assert-Contains -Presented $result.number -Expected 11
# }