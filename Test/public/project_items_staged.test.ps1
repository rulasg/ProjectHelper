
function Test_SyncProjectItemsStaged_NoStaged {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ;
    # $itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    Start-MyTranscript
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    $t = Stop-MyTranscript

    Assert-Contains -Presented $t -Expected "Nothing to commit"
    Assert-IsNull -Object $result
}

function Test_SyncProjectItemsStaged_SUCCESS_Number{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "I_kwDOPrRnkc7KkwSq"

    $fieldName = "field-number" 
    $fieldBeforeValueNumber = 111.0
    $fieldValue = "10,1" 
    $fieldValueToUpdate = "10.1"
    $fieldId = "PVTF_lADOAlIw4c4BCe3Vzg0rhjU"
    $type = "number"

    $mockItems = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId
            Value      = $fieldValueToUpdate
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItems) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type {Type}'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{Type}', $type

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project
    # MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldName $fieldValue

    # Act- Staged
    # Check that show shows the display value
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-AreEqual -Expected $fieldValue -Presented $staged.$itemId1.$fieldId.Value

    $showStaged = Show-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber | Show-ProjectItemStaged
    Assert-AreEqual -Expected $fieldValue -Presented $showStaged.$fieldName.Value
    Assert-AreEqual -Expected $fieldBeforeValueNumber -Presented $showStaged.$fieldName.Before

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Assert
    Assert-IsTrue -Condition $result

    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged
    
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldValue -Presented $item1.$fieldName
}

function Test_SyncProjectItemsStaged_SUCCESS_Date{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "I_kwDOPrRnkc7KkwSq"

    $fieldName = "field-date" 
    $fieldBeforeValueDate = "2025-09-01"
    $fieldValue = "2021-01-10"
    $fieldValueToUpdate = "2021-01-10"
    $fieldId = "PVTF_lADOAlIw4c4BCe3Vzg0rhlU"
    $type = "date"

    $mockItems = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId
            Value      = $fieldValueToUpdate
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItems) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type {Type}'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{Type}', $type

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldName $fieldValue

    # Act- Staged
    # Check that show shows the display value
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-AreEqual -Expected $fieldValue -Presented $staged.$itemId1.$fieldId.Value

    $showStaged = Show-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber | Show-ProjectItemStaged
    Assert-AreEqual -Expected $fieldValue -Presented $showStaged.$fieldName.Value
    Assert-AreEqual -Expected $fieldBeforeValueDate -Presented $showStaged.$fieldName.Before

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Assert
    Assert-IsTrue -Condition $result
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldValueToUpdate -Presented $item1.$fieldName
}

function Test_SyncProjectItemsStaged_SUCCESS_SingleSelect{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    $projectId = $p.id

    # project item issuue
    $item = $p.pullrequest
    $field = $p.fieldsingleselect

    $itemId1 = $item.id
    
    $fieldName = $field.name
    $fieldId = $field.id
    $type = "singleSelectOptionId"

    $fieldBeforeValueSingleSelect = $item.fieldsingleselect.name
    $fieldNewValue = $field.options[1].name
    $fieldNewValueId = $field.options[1].id

    $mockItems = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId
            Value      = $fieldNewValue
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItems) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type {Type}'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $fieldNewValueId
        $command = $command -replace '{Type}', $type

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project
    MockCall_GetProject -MockProject $p -Cache
    

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldName $fieldNewValue

    $expectedStaged = @{
        $($itemId1) = @{
            $($fieldId) = $fieldNewValue
        }
    }

    # Act- Staged
    # Confirm that the changes are staged
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-AreEqual -Expected $expectedStaged.Count -Presented $staged.Count -Comment "Items staged"
    foreach($id in $expectedStaged.Keys){
        foreach($field in $expectedStaged.$id.Keys){
            Assert-AreEqual -Expected $expectedStaged.$id.$field -Presented $staged.$id.$field.Value -Comment "Item $id Field $field"
        }
    }

    $showStaged = Show-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber | Show-ProjectItemStaged
    Assert-AreEqual -Expected $fieldNewValue -Presented $showStaged.$fieldName.Value
    Assert-AreEqual -Expected $fieldBeforeValueSingleSelect -Presented $showStaged.$fieldName.Before

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Assert
    Assert-IsTrue -Condition $result
    
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldNewValue -Presented $item1.$fieldName
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_Issue_NotCached {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    $contentId1 = "I_kwDOPrRnkc7KkwSq"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Define an array of objects to de updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
            Value      = "new value of the comment 10"
            ResultFile = "invoke-GitHubUpdateItemValue-PVTI_lADOAlIw4c4BCe3Vzgeiodc-PVTF_lADOAlIw4c4BCe3Vzg0rhko.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "title"
            TitleValue = "new value of the title"
            BodyValue  = ""
            ResultFile = "invoke-UpdateIssue-$contentId1.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = "new value of the body"
            ResultFile = "invoke-UpdateIssue-$contentId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Get-Item direct
    Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename invoke-getitem-$itemId1.json" -Alias "Invoke-GetItem -ItemId $itemId1"

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_PullRequest_NotCached {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "PR_kwDOPrRnkc6nndcE"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Define an array of objects to de updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
            Value      = "new value of the comment 10"
            ResultFile = "invoke-GitHubUpdateItemValue-PVTI_lADOAlIw4c4BCe3Vzgeiodc-PVTF_lADOAlIw4c4BCe3Vzg0rhko.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "title"
            TitleValue = "new value of the title"
            BodyValue  = ""
            ResultFile = "invoke-UpdatePullRequest-$contentId1.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = "new value of the body"
            ResultFile = "invoke-UpdatePullRequest-$contentId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Get-Item direct
    Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename invoke-getitem-$itemId1.json" -Alias "Invoke-GetItem -ItemId $itemId1"

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_DraftIssue_NotCached {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeiodc"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Define an array of objects to de updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
            Value      = "new value of the comment 10"
            ResultFile = "invoke-GitHubUpdateItemValue-PVTI_lADOAlIw4c4BCe3Vzgeiodc-PVTF_lADOAlIw4c4BCe3Vzg0rhko.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = "DI_lADOAlIw4c4BCe3VzgJwmkk"
            FieldId    = "title"
            TitleValue = "new value of the title"
            BodyValue  = ""
            ResultFile = "invoke-UpdateDraftIssue-DI_lADOAlIw4c4BCe3VzgJwmkk.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = "DI_lADOAlIw4c4BCe3VzgJwmkk"
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = "new value of the body"
            ResultFile = "invoke-UpdateDraftIssue-DI_lADOAlIw4c4BCe3VzgJwmkk.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Get-Item direct
    Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename invoke-getitem-$itemId1.json" -Alias "Invoke-GetItem -ItemId $itemId1"

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_Issue {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700

    # Mock this call to cache the project in the test
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $projectId = $project.ProjectId

    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    $contentId1 = "I_kwDOPrRnkc7KkwSq"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10" ; $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Invoke field updates
    $mockItemsComments = @(
        @{
            ItemId  = $itemId1
            FieldId = $fieldId1
            Value   = "new value of the comment 10"
            ResultFile = "invoke-GitHubUpdateItemValue-$($itemId1)-$($fieldId1).json"
        }
    )
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Invoke Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "title"
            TitleValue = $fieldTitleValue1
            BodyValue  = ""
            ResultFile = "invoke-UpdateIssue-$contentId1.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = $fieldBodyValue1
            ResultFile = "invoke-UpdateIssue-$contentId1.json"
        }
    )
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue

        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_PullRequest {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700

    # Mock this call to cache the project in the test
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    
    $project   = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $projectId = $project.ProjectId

    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # project item pull request
    $itemId1    = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "PR_kwDOPrRnkc6nndcE"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10" ; $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1   = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody     = "Body"  ; $fieldBodyValue1  = "new value of the body"

    # Invoke field updates
    $mockItemsComments = @(
        @{
            ItemId    = $itemId1
            FieldId   = $fieldId1
            Value     = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$($itemId1)-$($fieldId1).json"
        }
    )
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}',   $item.ItemId
        $command = $command -replace '{FieldId}',  $item.FieldId
        $command = $command -replace '{Value}',    $item.Value
        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Invoke Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "title"
            TitleValue = $fieldTitleValue1
            BodyValue  = ""
            ResultFile = "invoke-UpdatePullRequest-$contentId1.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = $fieldBodyValue1
            ResultFile = "invoke-UpdatePullRequest-$contentId1.json"
        }
    )
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}',    $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}',  $item.BodyValue
        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project (skip items)
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields (keep same order pattern as Issue test)
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1   $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody     $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    Assert-IsTrue -Condition $result

    # Staged list is empty (same assertion style as Issue test)
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1   -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1    -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_SUCCESS_Content_DraftIssue {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "octodemo" ; $ProjectNumber = 700

    # Cache project first
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    $project   = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $projectId = $project.ProjectId

    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # project item draft issue
    $itemId1     = "PVTI_lADOAlIw4c4BCe3Vzgeiodc"
    $contentId1  = "DI_lADOAlIw4c4BCe3VzgJwmkk"

    $fieldComment1       = "field-text"
    $fieldCommentValue1  = "new value of the comment 10"
    $fieldId1            = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1         = "Title"
    $fieldTitleValue1    = "new value of the title"
    $fieldBody           = "Body"
    $fieldBodyValue1     = "new value of the body"

    # Invoke field updates
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$($itemId1)-$($fieldId1).json"
        }
    )
    foreach ($item in $mockItemsComments) {
        $command = 'Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}',   $item.ItemId
        $command = $command -replace '{FieldId}',  $item.FieldId
        $command = $command -replace '{Value}',    $item.Value
        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Invoke Content updates
    $mockItemsTitles = @(
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "title"
            TitleValue = $fieldTitleValue1
            BodyValue  = ""
            ResultFile = "invoke-UpdateDraftIssue-$contentId1.json"
        },
        @{
            ItemId     = $itemId1
            ContentId  = $contentId1
            FieldId    = "body"
            TitleValue = ""
            BodyValue  = $fieldBodyValue1
            ResultFile = "invoke-UpdateDraftIssue-$contentId1.json"
        }
    )
    foreach ($item in $mockItemsTitles) {
        $command = 'Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}',    $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}',  $item.BodyValue
        Set-InvokeCommandMock -Command "Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project (skip items)
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields (match order used in Issue / PullRequest tests)
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1   $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody     $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsTrue -Condition $result

    # Staged list is empty (consistent assertion style)
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1   -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1    -Presented $item1.$fieldBody
}

function Test_ShowProjectItemsStaged {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    MockCall_GetProject_700
    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $i = $p.pullrequest
    $pr = $p.issue
    $fieldText = $p.fieldtext
    $fieldSingleSelect = $p.fieldsingleselect
    $fielddate = $p.fielddate

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $result

    $projectBefore = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Item 1
    $itemId1 = $i.id

    $fieldComment1 = $fieldText.name ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldCommentValue1_Before = $projectBefore.items.$itemId1.$fieldComment1

    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldTitleValue1_Before = $projectBefore.items.$itemId1.$fieldTitle1

    $fieldStatus = $fieldSingleSelect.name ; $fieldStatusValue1 = $fieldSingleSelect.options[1].name
    $fieldStatusValue1_Before = $projectBefore.items.$itemId1.$fieldStatus

    $fieldDate = $fielddate.name ; $fieldDateValue1 = "2024-03-31"
    $fieldDateValue1_Before = $projectBefore.items.$itemId1.$fieldDate

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldStatus $fieldStatusValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldDate $fieldDateValue1

    # Item 2
    $itemId2 = $pr.id
    $fieldComment2 = $fieldText.name ; $fieldCommentValue2 = "new value of the comment 11"
    $fieldTitle2 = "Title" ; $fieldTitleValue2 = "new value of the title 11"

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId2 $fieldComment2 $fieldCommentValue2
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId2 $fieldTitle2 $fieldTitleValue2

    # Act all staged items
    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber

    Assert-Count -Expected 2 -Presented $result

    $result1 = $result | Where-Object { $_.id -eq $itemId1 }
    # Assert-AreEqual -Expected "DraftIssue" -Presented $result1.type
    Assert-Contains -Expected $fieldComment1 -Presented $result1.FieldsName
    Assert-Contains -Expected $fieldTitle1 -Presented $result1.FieldsName
    Assert-Contains -Expected $fieldStatus -Presented $result1.FieldsName

    $result2 = $result | Where-Object { $_.id -eq $itemId2 }
    # Assert-AreEqual -Expected "PullRequest" -Presented $result2.type
    Assert-Contains -Expected $fieldComment2 -Presented $result2.FieldsName
    Assert-Contains -Expected $fieldTitle2 -Presented $result2.FieldsName

    # Act single item

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber -Id $itemId1

    Assert-Count -Expected 4 -Presented $result

    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $result.$fieldComment1.Value
    Assert-AreEqual -Expected $fieldCommentValue1_Before -Presented $result.$fieldComment1.Before

    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $result.$fieldTitle1.Value
    Assert-AreEqual -Expected $fieldTitleValue1_Before -Presented $result.$fieldTitle1.Before

    Assert-AreEqual -Expected $fieldStatusValue1 -Presented $result.$fieldStatus.Value
    Assert-AreEqual -Expected $fieldStatusValue1_Before -Presented $result.$fieldStatus.Before

    Assert-AreEqual -Expected $fieldDateValue1 -Presented $result.$fieldDate.Value
    Assert-AreEqual -Expected $fieldDateValue1_Before -Presented $result.$fieldDate.Before
}

function Test_TestProjectItemStaged {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.Owner ; $ProjectNumber = $p.Number
    $i = $p.issue
    $f = $p.fieldtext
    $fieldName = "field-text"
    $fieldValue = "some value"


    # no project information available
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Project is cached
    MockCall_GetProject_700 -Cache
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Edit some thing
    $params = @{
        ProjectId     = $p.Id
        ItemId        = $i.Id
        FieldId       = $f.Id
        Type          = "text"
        Value         = $fieldValue
    }
    MockCall_GitHubUpdateItemValues @params
    MockCall_GetItem -ItemId $i.Id
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $i.Id $fieldName $fieldValue

    # Act
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsTrue -Condition $result

}

function Test_SyncProjectItemsStagedAsync_debug {

    Assert-SkipTest
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $params = @{
        SourceOwner              = "github"
        DestinationProjectNumber = "9279"
        FieldSlug                = "oa_"
        DestinationOwner         = "github"
        SourceProjectNumber      = "20521"
    }

    $result = Update-ProjectItemsBetweenProjects @params

    Assert-NotNull -Presented $result

    Show-ProjectItemStaged

    Sync-ProjectItemStagedAsync

    Assert-NotImplemented

}

function Test_Sync_ProjectDatabaseAsync_ClearValues{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Convert-Path

    $p = Get-Mock_Project_700 ; $Owner = $p.Owner ; $ProjectNumber = $p.Number
    $i = $p.issue
    $f = $p.fieldtext
    $fss = $p.fieldsingleselect

    $projectId = $p.Id 
    $itemId1 = $i.Id
    $fieldComment1 = $f.name  ; $fieldComment1Id = $f.Id ; $fieldCommentName = "field-text"
    $fieldPriority1 = $fss.name ; $fieldPriority1Id = $fss.Id ; $fieldPriorityName = "field-singleselect"

    # Edit-ProjectItem will call Get-Project with SkipItems
    # This test is to confirm the sync works with the project and items
    # Cache the project with items
    MockCall_GetProject_700 -Cache

    # Mock clear command for empty comment field (using async alias)
    $clearCommand = 'Import-Module {projecthelper} ; Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{projecthelper}', $moduleRootPath
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldComment1Id
    # MockCallJsonAsync -Command $clearCommand -FileName "clearProjectV2ItemFieldValue.json"
    MockCallJsonAsync -Command $clearCommand -FileName "invoke-clearProjectV2ItemFieldValue-$projectId-$itemId1-$fieldComment1Id.json"


    # Mock clear command for empty priority field (using async alias)
    $clearCommand = 'Import-Module {projecthelper} ; Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{projecthelper}', $moduleRootPath
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldPriority1Id
    # MockCallJsonAsync -Command $clearCommand -FileName "clearProjectV2ItemFieldValue.json"
    MockCallJsonAsync -Command $clearCommand -FileName "invoke-clearProjectV2ItemFieldValue-$projectId-$itemId1-$fieldPriority1Id.json"

    # Stage the values - clear comment (empty string) and update title
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 ""
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldPriority1 ""

    Start-MyTranscript
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
    $transcript = Stop-MyTranscript2

    # Return true
    Assert-IsTrue -Condition $result

    # Verify clear and update commands were called by checking mock invocations
    # The transcript should show both operations on async: Calling and Saving
    @(
        "Saving [$projectId/$itemId1/$fieldComment1Id ($fieldCommentName) = """" ] ..."
        "Calling to update ItemField Async[True][$projectId/$itemId1/$fieldComment1Id (text) = """" ]"
        "Done"
        "Saving [$projectId/$itemId1/$fieldPriority1Id ($fieldPriorityName) = """" ] ..."
        "Calling to update ItemField Async[True][$projectId/$itemId1/$fieldPriority1Id (singleSelectOptionId) = """" ]"
    ) | ForEach-Object { 
        Assert-Contains -Presented $transcript -Expected $_ -Comment "Not found in transcript: '$_'"
    }

    # Staged list should be empty after successful sync
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    # Verify the values in the database
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldComment1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldPriority1
}

function Test_Sync_ProjectDatabase_ClearValues{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.Owner ; $ProjectNumber = $p.Number
    $i = $p.issue
    $f = $p.fieldtext
    $fss = $p.fieldsingleselect

    $projectId = $p.Id 
    $itemId1 = $i.Id
    $fieldComment1 = $f.name  ; $fieldComment1Id = $f.Id ; $fieldCommentName = "field-text"
    $fieldPriority1 = $fss.name ; $fieldPriority1Id = $fss.Id ; $fieldPriorityName = "field-singleselect"

    # Edit-ProjectItem will call Get-Project with SkipItems
    # This test is to confirm the sync works with the project and items
    # Cache the project with items
    MockCall_GetProject_700 -Cache

    # Mock clear command for empty comment field (using async alias)
    $clearCommand = 'Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldComment1Id
    MockCallJson -Command $clearCommand -FileName "invoke-clearProjectV2ItemFieldValue-$projectId-$itemId1-$fieldComment1Id.json"

    # Mock clear command for empty priority field (using async alias)
    $clearCommand = 'Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldPriority1Id
    MockCallJson -Command $clearCommand -FileName "invoke-clearProjectV2ItemFieldValue-$projectId-$itemId1-$fieldPriority1Id.json"

    # Stage the values - clear comment (empty string) and update title
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 ""
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldPriority1 ""

    Start-MyTranscript
    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    $transcript = Stop-MyTranscript

    # Return true
    Assert-IsTrue -Condition $result

    # Verify clear and update commands were called by checking mock invocations
    # The transcript should show both operations on async: Calling and Saving
    @(
        "Saving [$projectId/$itemId1/$fieldComment1Id ($fieldCommentName) = """" ] ..."
        "Calling to update ItemField Async[False][$projectId/$itemId1/$fieldComment1Id (text) = """" ]"
        "Done"
        "Saving [$projectId/$itemId1/$fieldPriority1Id ($fieldPriorityName) = """" ] ..."
        "Calling to update ItemField Async[False][$projectId/$itemId1/$fieldPriority1Id (singleSelectOptionId) = """" ]"
    ) | ForEach-Object { 
        Assert-Contains -Presented $transcript -Expected $_ -Comment "Not found in transcript: '$_'"
    }

    # Staged list should be empty after successful sync
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged

    # Verify the values in the database
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldComment1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldPriority1
}

# For some reason Stop-MyTranscript is failing calling Export-MyTranscript for one test.
# Merging both functions here to avoid the issue for this test.
function Stop-MyTranscript2 {

    $null = Stop-Transcript

    $transcriptContent = Get-Content -Path $TEST_TRANSCRIPT_FILE
    Remove-Item -Path $TEST_TRANSCRIPT_FILE

    $i = 0..($transcriptContent.Count - 1) | Where-Object { $transcriptContent[$_] -eq "**********************" }

    $firstLine = $i[1] + 1
    $lastLine = $i[2] - 1

    $ret = $transcriptContent[$firstLine..$lastLine]

    return $ret
}