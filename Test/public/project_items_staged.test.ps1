
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

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'

    $result = Show-ProjectItemStaged -Owner $owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $result

    $projectBefore = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Item 1
    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"

    $fieldComment1 = "Comment" ; $fieldCommentValue1 = "new value of the comment 10"
    $fieldCommentValue1_Before = $projectBefore.items.$itemId1.$fieldComment1

    $fieldTitle1 = "Title" ; $fieldTitleValue1 = "new value of the title"
    $fieldTitleValue1_Before = $projectBefore.items.$itemId1.$fieldTitle1

    $fieldStatus = "Status" ; $fieldStatusValue1 = "Done"
    $fieldStatusValue1_Before = $projectBefore.items.$itemId1.$fieldStatus

    $fieldDate = "Next Action Date" ; $fieldDateValue1 = "2024-03-31"
    $fieldDateValue1_Before = $projectBefore.items.$itemId1.$fieldDate

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 $fieldCommentValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldTitle1 $fieldTitleValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldStatus $fieldStatusValue1
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldDate $fieldDateValue1

    # Item 2
    $itemId2 = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment2 = "Comment" ; $fileCommentValue2 = "new value of the comment 11"
    $fieldTitle2 = "Title" ; $fileTitleValue2 = "new value of the title 11"

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId2 $fieldComment2 $fileCommentValue2
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId2 $fieldTitle2 $fileTitleValue2

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

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # no project information available
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Project is cached
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $null = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber
    $result = Test-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsFalse -Condition $result

    # Edit some thing
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubUpdateItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTF_lADOBCrGTM4ActQazgSl5GU -Value "new value of the comment 10" -Type text'
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber PVTI_lADOBCrGTM4ActQazgMuXXc "Comment" "new value of the comment 10"

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

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    $moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Convert-Path

    $projectId = "PVT_kwDOBCrGTM4ActQa"
    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldComment1 = "Comment"  ; $fieldComment1Id = "PVTF_lADOBCrGTM4ActQazgSl5GU"
    $fieldPriority1 = "Priority" ; $fieldPriority1Id ="PVTSSF_lADOBCrGTM4ActQazgSl5LY"

    # Edit-ProjectItem will call Get-Project with SkipItems
    # This test is to confirm the sync works with the project and items
    # Cache the project with items
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Mock clear command for empty comment field (using async alias)
    $clearCommand = 'Import-Module {projecthelper} ; Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{projecthelper}', $moduleRootPath
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldComment1Id
    MockCallJsonAsync -Command $clearCommand -FileName "clearProjectV2ItemFieldValue.json"

    # Mock clear command for empty priority field (using async alias)
    $clearCommand = 'Import-Module {projecthelper} ; Invoke-GitHubClearItemValues -ProjectId {ProjectId} -ItemId {ItemId} -FieldId {FieldId}'
    $clearCommand = $clearCommand -replace '{projecthelper}', $moduleRootPath
    $clearCommand = $clearCommand -replace '{ProjectId}', $projectId
    $clearCommand = $clearCommand -replace '{ItemId}', $itemId1
    $clearCommand = $clearCommand -replace '{FieldId}', $fieldPriority1Id
    MockCallJsonAsync -Command $clearCommand -FileName "clearProjectV2ItemFieldValue.json"

    # Stage the values - clear comment (empty string) and update title
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 ""
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldPriority1 ""

    Start-MyTranscript
    $result = Sync-ProjectItemStagedAsync -Owner $Owner -ProjectNumber $ProjectNumber -SyncBatchSize 2
    $transcript = Stop-MyTranscript

    # Return true
    Assert-IsTrue -Condition $result

    # Verify clear and update commands were called by checking mock invocations
    # The transcript should show both operations

    # Staged list should be empty after successful sync
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $staged

    # Verify the values in the database
    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldComment1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldPriority1

}

function Test_CommitProjectItemsStaged_SUCCESS_Emptyfield{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164

    # Item id 10
    # Name                           Value
    # ----                           -----
    # id                             PVTI_lADOBCrGTM4ActQazgMuXXc
    # number
    # Severity                       Nice⭐️
    # Status                         Todo
    # TimeTracker                    890
    # Comment                        This
    # body                           some content in body
    # Assignees                      rulasg
    # UserStories                    8
    # Title                          A draft in the project
    # Priority                       🥵High
    # url
    # type                           DraftIssue

    $itemId1 = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldComment1 = "Comment"
    $fieldPriority1 = "Priority"

    # Edit-ProjectItem will call Get-Project with SkipItems
    # This test is to confirm the sync works with the project and items
    # Cache the project with items
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubClearItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTF_lADOBCrGTM4ActQazgSl5GU'
    MockCallJson -FileName 'updateProjectV2ItemFieldValue.json' -Command 'Invoke-GitHubClearItemValues -ProjectId PVT_kwDOBCrGTM4ActQa -ItemId PVTI_lADOBCrGTM4ActQazgMuXXc -FieldId PVTSSF_lADOBCrGTM4ActQazgSl5LY'

    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldComment1 ""
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber $itemId1 $fieldPriority1 ""

    $result = Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

    # Return true
    Assert-IsTrue -Condition $result

    # Staged list is empty
    $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    Assert-IsNull -Object $staged

    $item1 = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldComment1
    Assert-StringIsNullOrEmpty -Presented $item1.$fieldPriority1
}