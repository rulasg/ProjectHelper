
function Test_GetProjectItem_SUCCESS{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $projectNumber = $p.number
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

function Test_GetProjectItem_Comments{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $projectNumber = $p.number
    $i = $p.issue
    $itemId = $i.id

    MockCall_GetProject $p -Cache

    #Act
    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    $c = $i.comments
    Assert-Count -Expected $c.totalCount -Presented $result.comments
    Assert-AreEqual -Expected $c.propertyCount -Presented $result.commentLast.Count
    Assert-AreEqual -Expected $c.last.body -Presented $result.commentLast.body
    Assert-AreEqual -Expected $c.last.author.login -Presented $result.commentLast.author
    Assert-AreEqual -Expected $c.last.url -Presented $result.commentLast.url
    Assert-AreEqual -Expected $c.last.createdAt -Presented $result.commentLast.createdAt
    Assert-AreEqual -Expected $c.last.updatedAt -Presented $result.commentLast.updatedAt
}

function Test_TestProjectItem_Success{
    
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $projectNumber = $p.number
    MockCall_GetProject $p -Cache

    $i = $p.issue

    # success
    $result = Test-ProjectItem -Url $i.url -Owner $owner -ProjectNumber $projectNumber
    Assert-IsTrue -Condition $result

    # Not found

    $result = Test-ProjectItem -Url "https://github.com/octodemo/Project-700/issues/999"
    Assert-IsFalse -Condition $result

}

function  Test_EditProjetItems_SUCCESS_Transformations{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject -MockProject $p -Cache

    $i = $p.issue
    $fieldTitle = "title"

    $itemId = $i.id
    $actualTitle = $i.title
    $actualRepoName = $i.repositoryName

    $newValue ="(*) [{{RepositoryName}}] {{Title}}"
    $finalValue = $newValue -replace '{{RepositoryName}}', $actualRepoName -replace '{{Title}}', $actualTitle

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $i.id $fieldTitle $newValue

    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected $finalValue -Presented $staged.$itemId.$fieldTitle.Value

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

    MockCall_GetProject_700
    $p = Get-Mock_Project_700 ; $Owner = $p.Owner ; $ProjectNumber = $p.Number
    $itemsCount = $p.items.totalCount
    $itemId = $p.issue.Id
    $fieldComment = "field-text" ; $fieldCommentValue = "new value of the comment 10.1"

    MockCall_GetItem -ItemId $itemId

    # Act empty as their is nothing staged yet
    $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber -Force
    Assert-Count -Expected $itemsCount -Presented $result

    # arrange modifyt to add staged
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId $fieldComment $fieldCommentValue

    # Act get staged. 1 modified
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

function Test_AddProjectItemDirect_AlreadyMember{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    $i = $p.issue

    MockCall_GetProject -MockProject $p

    # Act
    $result = Add-ProjectItemDirect -Url $i.url -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-AreEqual -Expected $i.id -Presented $result
}

function Test_ShowProjectItem_SUCCESS{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    MockCall_GetProject_700

    $p = Get-Mock_Project_700; $Owner = "octodemo" ; $ProjectNumber = 700

    $i = $p.issue
    $id = $i.Id
    $title = $i.title
    $status = $i.status

    # title refrence with differnt case and spaces

    $item = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $id

    # Act 0
    $result0 = $item | Format-ProjectItem
    
    Assert-Count -Expected 1 -Presented $result0

    Assert-AreEqual -Expected $id -Presented $result0[0].id
    Assert-AreEqual -Expected $title -Presented $result0[0].Title

    $result1 = $item | Format-ProjectItem -Attributes "id","Title","Status"
    
    Assert-Count -Expected 1 -Presented $result1

    Assert-AreEqual -Expected $id -Presented $result1[0].id
    Assert-AreEqual -Expected $title -Presented $result1[0].Title
    Assert-AreEqual -Expected $status -Presented $result1[0].Status
}

function Test_ShowProjectItem_SUCCESS_Multiple{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    MockCall_GetProject_700
    $p = Get-Mock_Project_700; $Owner = $p.owner; $ProjectNumber = $p.number

    # Arrange - get a few items using search-projectitem
    $items = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter $p.searchInTitle.titleFilter -PassThru
    $itemsCount = $items.Count
    Assert-Count -Expected $p.searchInTitle.Titles.Count -Presented $items

    $result = $items | Format-ProjectItem -Attributes "id","url","Status"

    Assert-Count -Expected $itemsCount -Presented $result

    # Get properties of the first item to verify
    $expectedProperties = @("id","url","Status")

    # Verify all items have the same structure
    for ($i = 1; $i -lt $result.Count; $i++) {
        $itemProps = $result[$i].PSObject.Properties.Name
        Assert-Count -Expected 3 -Presented $itemProps -Comment "Item $i should only have 3 properties"
        foreach ($prop in $expectedProperties) {
            Assert-Contains -Expected $prop -Presented $itemProps -Comment "Item $i should contain $prop property"
        }
    }
}

function Test_WhereLikeField_SUCCESS{

    Invoke-PrivateContext{

        $item = @{
            id = "1"
            title = "This is a sample title for testing"
        }
        
        # Test case 1: Single value match
        $result = $item | Test-WhereLikeField -Fieldname "title" -Values "sample"
        Assert-IsTrue -Condition $result
        
        # Test case 2: Multiple values match (AND logic)
        $result = $item | Test-WhereLikeField -Fieldname "title" -Values "sample","testing"
        Assert-IsTrue -Condition $result

        # Test case 3: Multiple values no match (AND logic)
        $result = $item | Test-WhereLikeField -Fieldname "title" -Values "sample","missing"
        Assert-IsFalse -Condition $result

        # Test case 4: No match
        $result = $item | Test-WhereLikeField -Fieldname "title" -Values "absent"
        Assert-IsFalse -Condition $result
    }
}

function Test_WhereLikeAnyField_SUCCESS {
    Invoke-PrivateContext {

        # Factors under test:
        # - Number of values (1 vs many)
        # - Number of fields that contain ALL values (0 vs 1 vs >1)
        # Implementation detail: AND match must occur within a single field.

        $item = @{
            id          = "1"
            title       = "Sample Title with alpha beta"
            description = "Feature notes include ALPHA"
            notes       = "edge BETA value"
        }

        # 1. 1 value; present in exactly 1 field
        $r = $item | Test-WhereLikeAnyField -Values "sample"
        Assert-IsTrue -Condition $r -Comment "Single value present in one field"

        # 2. 1 value; absent in all fields
        $r = $item | Test-WhereLikeAnyField -Values "missing"
        Assert-IsFalse -Condition $r -Comment "Single value absent"

        # 3. 1 value; present in multiple fields (still True)
        $r = $item | Test-WhereLikeAnyField -Values "beta"
        Assert-IsTrue -Condition $r -Comment "Value present in multiple fields"

        # 4. 2 values; both present in the SAME field (title) -> True
        $r = $item | Test-WhereLikeAnyField -Values "alpha","beta"
        Assert-IsTrue -Condition $r -Comment "Both values co-exist in one field"

        # 5. 2 values; distributed across different fields (no single field has both) -> False
        # 'alpha' (title/description), 'value' (notes)
        $r = $item | Test-WhereLikeAnyField -Values "alpha","value"
        Assert-IsFalse -Condition $r -Comment "Values split across fields; AND not satisfied"
    }
}
