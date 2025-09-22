
function Test_GetProjectItem_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    $i = $p.draftissue
    $f = $p.fieldtext

    $fieldComment = $f.name ; $fieldTitle = "Title"

    $itemId = $i.id
    $projectFieldTitleValue = $i.title
    $projectFieldCommentValue = $i.fieldtext
    $itemFieldTitleValue = $projectFieldTitleValue + " updated"
    $itemFieldCommentValue = $projectFieldCommentValue + " updated"

    # allow get project
    MockCall_GetProject_700

    # Even if id is in project we make a direct call when with Force
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId-updated.json"
    
    # Act get value from project
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $projectFieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $projectFieldTitleValue -Presented $result.$fieldTitle

    # Act with force - get value from direct call
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId -Force

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $itemFieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $itemFieldTitleValue -Presented $result.$fieldTitle

    # Edit to see the staged references
    $newFieldCommentValue = "new value of the comment 10.1"
    $newFieldTitleValue = "new value of the title 10.1"
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldComment $newFieldCommentValue
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldTitle $newFieldTitleValue

    # Act getting from cached project with staged values
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $newFieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $newFieldTitleValue -Presented $result.$fieldTitle
}


function Test_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700 ;
    #$itemsCount = 12 ; $fieldsCount = 18
    # MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'

    $before = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Item id 10
    # $title = "A draft in the project"

    $itemId = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    # $title_fieldid= "PVTF_lADOBCrGTM4ActQazgSkYm8"
    $title_fieldid= "title"

    $comment_fieldid = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"

    $fieldComment = "field-text" ; $fieldCommentValue = "new value of the comment 10.1" ; $fieldCommentValue_Before = $before.items.$itemId.$fieldComment
    $fieldTitle = "Title" ; $fieldTitleValue = "new value of the title 10.1" ; $fieldTitleValue_Before = $before.items.$itemId.$fieldTitle

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldComment $fieldCommentValue
    # $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldTitle $fieldTitleValue

    # Assert

    # Confirm that the new value is staged but the original value is not changed
    $after = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-AreEqual -Expected $fieldCommentValue_Before -Presented $after.items.$itemId.$fieldComment -Comment "The original value should not be changed"
    Assert-AreEqual -Expected $fieldTitleValue_Before -Presented $after.items.$itemId.$fieldTitle -Comment "The original value should not be changed"


    # Cofirm that the new value is staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-Contains -Expected $itemId -Presented $result.Keys

    Assert-Count -Expected 2 -Presented $result.$itemId
    Assert-AreEqual -Expected $fieldComment -Presented $result.$itemId.$comment_fieldid.Field.name
    Assert-AreEqual -Expected $fieldTitle -Presented $result.$itemId.$title_fieldid.Field.name

    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$comment_fieldid.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.$title_fieldid.Value
}

function Test_EditProjectItems_SameValue{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'

    $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    #$actualtitle = $prj.items.$itemId."Title"

    # Item id 10
    # $title = "A draft in the project"

    $itemId = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    #$title_fieldid= "PVTF_lADOBCrGTM4ActQazgSkYm8"
    #$comment_fieldid = "PVTF_lADOBCrGTM4ActQazgSl5GU"

    $fieldComment = "field-text" ; $fieldCommentValue = $prj.items.$itemId."field-text"
    $fieldTitle = "Title" ; $fieldTitleValue = $prj.items.$itemId."Title"

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 0 -Presented $result.Keys
}

function Test_EditProjectItems_Direct{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700

    # No sync of project with items allowed just with skipitems
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipitems

    $itemId = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    $fieldComment = "field-text" ; $fieldCommentValue = "new value of the comment 10.1"
    $fieldId = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Direct edit of the item
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -FieldName $fieldComment -Value $fieldCommentValue

    # Get the staged item
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys[0]
    Assert-AreEqual -Expected $fieldComment -Presented $result.$itemId.$fieldId.Field.name
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$fieldId.Value

}

function Test_UpdateProjectDatabase_Fail_With_Staged{
    # When changes are staged list update should fail.
    # As Update-ProjectDatabase is a private function, we will test it through the public function Get-ProjectItemList with Force

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 164 ; $itemsCount = 1700
    $itemId = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment 10.1"
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'


    # Calling Get-ProjectItemList with Force to trigger update-projectdatabase that should fail as their are
    # staged changes not yet synced to remote.
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

    $result = Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldComment $fieldCommentValue
    Assert-IsNull -Object $result

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys

    # This call should fail as there are staged changes
    Start-MyTranscript
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $tt = Stop-MyTranscript

    Assert-IsNull -Object $result
    $message = "Error: Can not get item list with Force [True]; There are unsaved changes. Restore changes with Reset-ProjectItemStaged or sync projects with Sync-ProjectItemStaged first and try again"
    Assert-Contains -Expected $message -Presented $tt

    # Reset the staged changes
    Reset-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $result.Keys
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

}

function Test_FindProjectItem_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 164700
    #$itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $title = "Issue 455d29e3"
    $itemId1 = "PVTI_lADNJr_OALnx2s4Fqq8f"
    $itemId2 = "PVTI_lADNJr_OALnx2s4Fqq8p"
    $subtitle = $title.Substring(4,4)
    $subtitle

    # Item not found
    $result = Find-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Title "No item with this title"
    Assert-IsNull -Object $result

    # Several items with similar title
    $result = Find-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Title "*$subtitle*" -IncludeDone
    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Expected $itemId1 -Presented $result.id
    Assert-Contains -Expected $itemId2 -Presented $result.id

    # Not Match
    $result = Find-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Title $title -Match
    Assert-IsNull -Object $result

    # Match
    $result = Find-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Title "$title 1" -Match
    Assert-Count -Expected 1 -Presented $result
    Assert-Contains -Expected $itemId1 -Presented $result.id
}

function Test_FindProjectItem_FAIL{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 1700
    $erroMessage= "Error: Project not found. Check owner and projectnumber"

    Mock_DatabaseRoot

    MockCall_GitHubOrgProjectWithFields_Null  -Owner $owner -ProjectNumber $projectNumber

    # Run the command
    Start-MyTranscript
    $result = Find-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Title "no title"
    $tt = Stop-MyTranscript
    
    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage -Presented $tt
}

function Test_SearchProjectItem_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700

    # title refrence with differnt case and spaces
    $filter = "epic"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    # Act 1
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter $filter -IncludeDone

    Assert-Count -Expected 2 -Presented $result
    
    Assert-Contains -Expected "EPIC 1 " -Presented $result.Title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRO0" -Presented $result.id
    Assert-Contains -Expected "EPIC 2"  -Presented $result.Title
    Assert-Contains -Expected "PVTI_lADOBCrGTM4ActQazgMtRPg" -Presented $result.id

    # Act 2
    $result = Search-ProjectItem 68 -IncludeDone # TimeTracker value 684

    Assert-Count -Expected 1 -Presented $result
    Assert-AreEqual -Expected "Issue 455d29e3 2" -Presented $result[0].Title
    Assert-AreEqual -Expected "PVTI_lADNJr_OALnx2s4Fqq8p" -Presented $result[0].id

    # Act 3
    $result = Search-ProjectItem "ProjectDemoTest-repo-front" 
    Assert-Count -Expected 5 -Presented $result

}

function Test_GetItemDirect_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $itemId = "PVTI_lADNJr_OADU3Ys4GAgVO"
    $itemUrl = "https://github.com/github/sales/issues/11742"
    $contentId ="I_kwDOAFbrpM6s_fNK"

    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    $result = Get-ProjectItemDirect -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $itemUrl -Presented $result.url
    Assert-AreEqual -Expected $contentId -Presented $result.contentId

}

function Test_ShowProjectItem_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $id = "PVTI_lADOBCrGTM4ActQazgMtRO0"
    $title = "EPIC 1 "
    $status = "Todo"

    # title refrence with differnt case and spaces

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    
    $item = Find-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Title $title -Match

    $result = $item | Show-ProjectItem -AdditionalFields "Status"
    
    Assert-Count -Expected 1 -Presented $result

    Assert-AreEqual -Expected $id -Presented $result[0].id
    Assert-AreEqual -Expected $title -Presented $result[0].Title
    Assert-AreEqual -Expected $status -Presented $result[0].Status
    
}

function Test_ShowProjectItem_SUCCESS_Multiple{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700


    # title refrence with differnt case and spaces

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    
    $items = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter "Issue*"

    $result = $items | Show-ProjectItem -AdditionalFields "Status"
    
    Assert-Count -Expected 8 -Presented $Items
    Assert-Count -Expected 8 -Presented $result

    # Get properties of the first item to verify
    $expectedProperties = @("id", "Title", "Status")

    # Verify all items have the same structure
    for ($i = 1; $i -lt $result.Count; $i++) {
        $itemProps = $result[$i].PSObject.Properties.Name
        Assert-Count -Expected 3 -Presented $itemProps -Comment "Item $i should only have 3 properties"
        foreach ($prop in $expectedProperties) {
            Assert-Contains -Expected $prop -Presented $itemProps -Comment "Item $i should contain $prop property"
        }
    }
}