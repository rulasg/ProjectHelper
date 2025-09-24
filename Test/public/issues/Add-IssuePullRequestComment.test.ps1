
function Test_AddIssueComment_SUCCESS_Using_Cache{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number
    $i = $p.Issue
    $contentId = $i.contentId
    $comment = "sample comment 1"

    MockCall_GetProject_700

    Set-ProjectHelperEnvironment -Owner $owner -ProjectNumber $projectNumber -DisplayFields @("Status","FieldText")

    MockCallJson -Command "Invoke-AddIssueComment -SubjectId $contentId -Comment ""$comment""" -FileName "invoke-addissuecomment-$contentId.json"

    #Act
    $result = Add-IssuePullRequestCommentDirect -ItemId $i.id -Comment $comment

    # $result is a valid url
    Assert-IsUrl -Presented $result
}

function Test_AddIssueComment_SUCCESS_Using_Direct{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 
    $i = $p.Issue
    $id = $i.id
    $contentId = $i.contentId
    $comment = "sample comment 1"

    MockCallJson -Command "Invoke-GetItem -ItemId $id" -FileName "invoke-getitem-$id.json"

    MockCallJson -Command "Invoke-AddIssueComment -SubjectId $contentId -Comment ""$comment""" -FileName "invoke-addissuecomment-$contentId.json"

    #Act
    $result = Add-IssuePullRequestCommentDirect -ItemId $i.id -Comment $comment

    # $result is a valid url
    Assert-IsUrl -Presented $result
}

function Test_AddIssueComment_SUCCESS_Using_Direct_PR{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 
    $i = $p.PullRequest
    $id = $i.id
    $contentId = $i.contentId
    $comment = "sample comment 1"

    MockCallJson -Command "Invoke-GetItem -ItemId $id" -FileName "invoke-getitem-$id.json"

    MockCallJson -Command "Invoke-AddIssueComment -SubjectId $contentId -Comment ""$comment""" -FileName "invoke-addissuecomment-$contentId.json"

    #Act
    $result = Add-IssuePullRequestCommentDirect -ItemId $i.id -Comment $comment

    # $result is a valid url
    Assert-IsUrl -Presented $result
}


function Assert-IsUrl{
    param(
        [string]$Presented
    )

    # Determine if the presented string is a valid absolute http/https URL
    $uri = $null
    $isUrl = [System.Uri]::TryCreate($Presented, [System.UriKind]::Absolute, [ref]$uri) -and $null -ne $uri -and $uri.Scheme -in @('http','https')

    Assert-IsTrue -Condition $isUrl
}