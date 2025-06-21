
function Test_GetProjectItem_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; 
    # $itemsCount = 12 ; $fieldsCount = 18
    $fieldComment = "Comment" ; $fieldTitle = "Title"

    
    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldTitleValue = "A draft in the project"
    $fieldCommentValue = "This"
    
    # allos get project with skipitems
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -skipitems
    
    # Getting an item not cached is null
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId
    Assert-IsNull -Object $result
    
    # Allow to get project with items for the FORCE
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId -Force

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle

    # Edit to see the staged references
    $fieldCommentValue = "new value of the comment 10.1"
    $fieldTitleValue = "new value of the title 10.1"
    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle
}

function Test_EditProjetItems_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; 
    #$itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $before = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    
    # Item id 10
    # $title = "A draft in the project" 

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $title_fieldid= "PVTF_lADOBCrGTM4ActQazgSkYm8"
    $comment_fieldid = "PVTF_lADOBCrGTM4ActQazgSl5GU"

    $fieldComment = "Comment" ; $fieldCommentValue = "new value of the comment 10.1" ; $fieldCommentValue_Before = $before.items.$itemId.$fieldComment
    $fieldTitle = "Title" ; $fieldTitleValue = "new value of the title 10.1" ; $fieldTitleValue_Before = $before.items.$itemId.$fieldTitle

    # Act
    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    # $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

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
    Assert-AreEqual -Expected "Comment" -Presented $result.$itemId.$comment_fieldid.Field.name
    Assert-AreEqual -Expected "Title" -Presented $result.$itemId.$title_fieldid.Field.name 

    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$comment_fieldid.Value
    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$itemId.$title_fieldid.Value
}

function Test_EditProejctItems_SameValue{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
    #$actualtitle = $prj.items.$itemId."Title"

    # Item id 10
    # $title = "A draft in the project"

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    #$title_fieldid= "PVTF_lADOBCrGTM4ActQazgSkYm8"
    #$comment_fieldid = "PVTF_lADOBCrGTM4ActQazgSl5GU"

    $fieldComment = "Comment" ; $fieldCommentValue = $prj.items.$itemId."Comment"
    $fieldTitle = "Title" ; $fieldTitleValue = $prj.items.$itemId."Title"

    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 0 -Presented $result.Keys
}

function Test_EditProejctItems_NumberDecimals{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -SkipItems

    # $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"

    # [DBG]:> $prj.fields.PVTF_lADOBCrGTM4ActQazgSkglc
    # Name                           Value
    # ----                           -----
    # dataType                       NUMBER
    # id                             PVTF_lADOBCrGTM4ActQazgSkglc
    # type                           ProjectV2Field
    # name                           TimeTracker

    $fieldNumber = "TimeTracker"

    "NotANumber","1.000.1","1,000,1" | ForEach-Object{

        # Not a valid value
        $hasThrow= $false
        try {
            Edit-ProjectItem $owner $projectNumber $itemId $fieldNumber "NotNumber"
        }
        catch {
            $hasThrow = $true
        }
        Assert-IsTrue -Condition $hasThrow -Comment "Should throw as the value is not a number"
    }

    "10.1","10,1" | ForEach-Object {
        Edit-ProjectItem $owner $projectNumber $itemId $fieldNumber $_
        $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
        Assert-Count -Expected 1 -Presented $result.Keys
        Assert-AreEqual -Expected 10.1 -Presented $result.$itemId.PVTF_lADOBCrGTM4ActQazgSkglc.Value
        Reset-ProjectItemStaged
    }

    "1,000.1","1.000,1" | ForEach-Object {
        Edit-ProjectItem $owner $projectNumber $itemId $fieldNumber $_
        $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
        Assert-Count -Expected 1 -Presented $result.Keys
        Assert-AreEqual -Expected 1000.1 -Presented $result.$itemId.PVTF_lADOBCrGTM4ActQazgSkglc.Value
        Reset-ProjectItemStaged
    }
}

function Test_EditProejctItems_Direct{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    
    # No sync of project with items allowed just with skipitems
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2-skipitems.json' -skipitems

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldComment = "Comment" ; $fieldCommentValue = "new value of the comment 10.1"
    
    # Get an item with no changes staged from a not cached project
    $result = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId
    Assert-IsNull -Object $result

    # Direct edit of the item
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -FieldName $fieldComment -Value $fieldCommentValue

    # Get the staged item
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys[0]
    Assert-AreEqual -Expected "Comment" -Presented $result.$itemId.PVTF_lADOBCrGTM4ActQazgSl5GU.Field.name
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.PVTF_lADOBCrGTM4ActQazgSl5GU.Value

    $result = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId
    Assert-AreEqual -Expected $itemId -Presented $result.id
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment
    Assert-Count -Expected 2 -Presented $result

}

function Test_UpdateProjectDatabase_Fail_With_Staged{
    # When changes are staged list update should fail.
    # As Update-ProjectDatabase is a private function, we will test it through the public function Get-ProjectItemList with Force

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ;
    $itemId = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment 10.1"
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'


    # Calling Get-ProjectItemList with Force to trigger update-projectdatabase that should fail as their are 
    # staged changes not yet synced to remote.
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

    $result = Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
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

