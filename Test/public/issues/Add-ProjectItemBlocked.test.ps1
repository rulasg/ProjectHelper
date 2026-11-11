function Test_AddProjectItemBlocked_SUCCESS_Pipeline {
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700
    MockCall_GetProject $p -Cache
    $item = $p.issue
    $blocker = Get-ProjectItem -ItemId $p.subIssueToShow.id -Owner $p.owner -ProjectNumber $p.number
    $secondBlocker = Get-ProjectItemByUrl -Url $p.subIssuesToAdd[0].url -Owner $p.owner -ProjectNumber $p.number -PassThru
    MockCallJson -Command "Invoke-AddBlockedBy -IssueId $($item.contentId) -BlockingIssueId $($blocker.contentId)" -File "invoke-addBlockedBy-success.json"
    MockCallJson -Command "Invoke-AddBlockedBy -IssueId $($item.contentId) -BlockingIssueId $($secondBlocker.contentId)" -File "invoke-addBlockedBy-second-blocker.json"

    # Act
    $result = @($blocker.id, $secondBlocker.id) | Add-ProjectItemBlocked -ItemId $item.id -Owner $p.owner -ProjectNumber $p.number

    # Assert
    Assert-Count -Expected 2 -Presented $result
    Assert-IsTrue -Condition $result[0]
    Assert-IsTrue -Condition $result[1]
}

function Test_AddProjectItemBlocked_NotFound {
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700
    MockCall_GetProject $p -Cache
    MockCallToNull -Command "Invoke-GetItem -ItemId missing"

    # Act
    $missingItem = Add-ProjectItemBlocked -ItemId missing -BlockingItemId $p.issue.id -Owner $p.owner -ProjectNumber $p.number -InformationVariable itemMessages
    $missingBlocker = Add-ProjectItemBlocked -ItemId $p.issue.id -BlockingItemId missing -Owner $p.owner -ProjectNumber $p.number -InformationVariable blockerMessages

    # Assert
    Assert-IsNull -Object $missingItem
    Assert-IsNull -Object $missingBlocker
    Assert-IsTrue -Condition (($itemMessages.MessageData.Message -join "`n").Contains("ItemId [missing] not found on project"))
    Assert-IsTrue -Condition (($blockerMessages.MessageData.Message -join "`n").Contains("BlockingItemId [missing] not found on project"))
}

function Test_AddProjectItemBlocked_InvalidInput {
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700
    MockCall_GetProject $p -Cache
    $params = @{ Owner = $p.owner; ProjectNumber = $p.number }

    # Act
    $draft = Add-ProjectItemBlocked -ItemId $p.draftissue.id -BlockingItemId $p.issue.id @params -InformationVariable draftMessages
    $pullRequest = Add-ProjectItemBlocked -ItemId $p.issue.id -BlockingItemId $p.pullrequest.id @params -InformationVariable pullRequestMessages
    $self = Add-ProjectItemBlocked -ItemId $p.issue.id -BlockingItemId $p.issue.id @params -InformationVariable selfMessages

    # Assert
    Assert-IsNull -Object $draft
    Assert-IsNull -Object $pullRequest
    Assert-IsNull -Object $self
    Assert-IsTrue -Condition (($draftMessages.MessageData.Message -join "`n").Contains("must be a GitHub Issue"))
    Assert-IsTrue -Condition (($pullRequestMessages.MessageData.Message -join "`n").Contains("must be a GitHub Issue"))
    Assert-IsTrue -Condition (($selfMessages.MessageData.Message -join "`n").Contains("cannot be blocked by itself"))
}

function Test_AddProjectItemBlocked_ERROR {
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700
    MockCall_GetProject $p -Cache
    $blocker = Get-ProjectItem -ItemId $p.subIssueToShow.id -Owner $p.owner -ProjectNumber $p.number
    $command = "Invoke-AddBlockedBy -IssueId $($p.issue.contentId) -BlockingIssueId $($blocker.contentId)"
    $params = @{ ItemId = $p.issue.id; BlockingItemId = $blocker.id; Owner = $p.owner; ProjectNumber = $p.number }
    MockCallThrow -Command $command -ExceptionMessage "Relationship would create a cycle"

    # Act
    $result = Add-ProjectItemBlocked @params -InformationVariable messages

    # Assert
    Assert-IsNull -Object $result
    Assert-IsTrue -Condition (($messages.MessageData.Message -join "`n").Contains("Relationship would create a cycle"))
}

function Test_AddProjectItemBlocked_ERROR_Response {
    # Arrange
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    $p = Get-Mock_Project_700
    MockCall_GetProject $p -Cache
    $blocker = Get-ProjectItem -ItemId $p.subIssueToShow.id -Owner $p.owner -ProjectNumber $p.number
    $command = "Invoke-AddBlockedBy -IssueId $($p.issue.contentId) -BlockingIssueId $($blocker.contentId)"
    $params = @{ ItemId = $p.issue.id; BlockingItemId = $blocker.id; Owner = $p.owner; ProjectNumber = $p.number }
    $success = Get-MockFileContentJson -FileName "invoke-addBlockedBy-success.json" -AsHashtable
    $responses = @(
        $null,
        @{ data = @{ addBlockedBy = @{ issue = @{ id = $p.issue.contentId } } } },
        @{ data = @{ addBlockedBy = @{ issue = @{ id = $blocker.contentId }; blockingIssue = @{ id = $p.issue.contentId } } } },
        @{ data = $success.data; errors = @(@{ message = "Permission denied" }) }
    )

    foreach ($response in $responses) {
        MockCallToObject -Command $command -OutObject $response

        # Act
        $result = Add-ProjectItemBlocked @params

        # Assert
        Assert-IsNull -Object $result
    }
}
