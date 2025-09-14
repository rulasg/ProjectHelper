function Test_SyncProjectItemsStaged_Async_NoStaged {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ;
    # $itemsCount = 12 ; $fieldsCount = 18
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    Start-MyTranscript
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
    $t = Stop-MyTranscript

    Assert-IsTrue -Condition $result
    Assert-Contains -Presented $t -Expected "Nothing to commit"
}

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_Issue_NotCached {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | split-path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeio4o"
    $contentId1 = "I_kwDOPrRnkc7KkwSq"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10" ; $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Define an array of objects to de updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
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
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber

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

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_PullRequest_NotCached {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | Split-Path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item pull request
    $itemId1 = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "PR_kwDOPrRnkc6nndcE"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"
    $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"

    # Define an array of objects to be updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Get-Item direct
    Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename invoke-getitem-$itemId1.json" -Alias "Invoke-GetItem -ItemId $itemId1"

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber

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

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_DraftIssue_NotCached {
    Assert-NotImplemented
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | Split-Path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

    $Owner = "octodemo" ; $ProjectNumber = 700
    $projectId = "PVT_kwDOAlIw4c4BCe3V"

    # project item issue
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeiodc"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"
    $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"

    # Define an array of objects to be updated mocked
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock Get-Item direct
    Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename invoke-getitem-$itemId1.json" -Alias "Invoke-GetItem -ItemId $itemId1"

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber

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

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_Issue {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | split-path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

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

    # Define an array of objects to de updated mocked
    $mockItemsComments = @(
        @{
            ItemId  = $itemId1
            FieldId = $fieldId1
            Value   = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    # Loop through the array and set the mock commands
    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId
        $command = $command -replace '{ItemId}', $item.ItemId
        $command = $command -replace '{FieldId}', $item.FieldId
        $command = $command -replace '{Value}', $item.Value
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Title and Body updates
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdateIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId
        $command = $command -replace '{title}', $item.TitleValue
        $command = $command -replace '{body}', $item.BodyValue
        $command = $command -replace '{modulepath}', $modulePath

        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock get-project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Edit fields
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act - Sync
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged.Keys.Count

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_PullRequest {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | Split-Path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

    $Owner = "octodemo" ; $ProjectNumber = 700

    # Cache project (with items) so it is stored locally
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $projectId = $project.ProjectId

    # Reset mocks keeping DB
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # Pull request item
    $itemId1 = "PVTI_lADOAlIw4c4BCe3VzgeioBY"
    $contentId1 = "PR_kwDOPrRnkc6nndcE"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10" ; $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Comment (text field) updates
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId `
                             -replace '{ItemId}', $item.ItemId `
                             -replace '{FieldId}', $item.FieldId `
                             -replace '{Value}', $item.Value `
                             -replace '{modulepath}', $modulePath
        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Title and Body (pull request content) updates
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdatePullRequest -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId `
                             -replace '{title}', $item.TitleValue `
                             -replace '{body}', $item.BodyValue `
                             -replace '{modulepath}', $modulePath
        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock project (skip items)
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Stage edits (order similar to Issue/DraftIssue tests)
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsTrue -Condition $result

    # Staged list empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged.Keys.Count

    # Validations
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_Async_SUCCESS_Content_DraftIssue {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $modulePath = $MODULE_PATH | Split-Path -Parent
    $moduleTestPath = Join-Path -Path $modulePath -ChildPath 'Test'

    $Owner = "octodemo" ; $ProjectNumber = 700

    # Cache project (with items) so it is stored locally
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700.json'
    $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force
    $projectId = $project.ProjectId

    # Reset mocks keeping DB
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    # Draft issue item
    $itemId1 = "PVTI_lADOAlIw4c4BCe3Vzgeiodc"
    $contentId1 = "DI_lADOAlIw4c4BCe3VzgJwmkk"

    $fieldComment1 = "field-text" ; $fieldCommentValue1 = "new value of the comment 10" ; $fieldId1 = "PVTF_lADOAlIw4c4BCe3Vzg0rhko"
    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldBody = "Body" ; $fieldBodyValue1 = "new value of the body"

    # Comment (text field) updates
    $mockItemsComments = @(
        @{
            ItemId     = $itemId1
            FieldId    = $fieldId1
            Value      = $fieldCommentValue1
            ResultFile = "invoke-GitHubUpdateItemValue-$itemId1-$fieldId1.json"
        }
    )

    foreach ($item in $mockItemsComments) {
        $command = 'Import-Module {modulepath} ; Invoke-GitHubUpdateItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId} -Value "{Value}" -Type text'
        $command = $command -replace '{ProjectId}', $projectId `
                             -replace '{ItemId}', $item.ItemId `
                             -replace '{FieldId}', $item.FieldId `
                             -replace '{Value}', $item.Value `
                             -replace '{modulepath}', $modulePath
        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Title and Body (draft issue content) updates
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
        $command = 'Import-Module {modulepath} ; Invoke-UpdateDraftIssue -Id {id} -Title "{title}" -Body "{body}"'
        $command = $command -replace '{id}', $item.ContentId `
                             -replace '{title}', $item.TitleValue `
                             -replace '{body}', $item.BodyValue `
                             -replace '{modulepath}', $modulePath
        Set-InvokeCommandMock -Command "Import-Module $moduleTestPath ; Get-MockFileContentJson -filename $($item.ResultFile)" -Alias $command
    }

    # Mock project (skip items)
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json' -skipItems

    # Stage edits (order similar to Issue test)
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldBody $fieldBodyValue1

    # Act
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsTrue -Condition $result

    # Staged list empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-Count -Expected 0 -Presented $staged.Keys.Count

    # Validations
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-AreEqual -Expected $fieldCommentValue1 -Presented $item1.$fieldComment1
    Assert-AreEqual -Expected $fieldTitleValue1 -Presented $item1.$fieldTitle1
    Assert-AreEqual -Expected $fieldBodyValue1 -Presented $item1.$fieldBody
}

function Test_SyncProjectItemsStaged_Async_debug {

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

    Sync-ProjectItemStagedAsyncAsync

    Assert-NotImplemented

}