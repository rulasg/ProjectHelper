function Test_EditProjectItems_FieldName{

    #Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    $fieldComment = $p.fieldtext.name ; $fieldCommentValue = "new value of the comment 10.1"
    $fieldId = $p.fieldtext.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -FieldName $fieldComment -Value $fieldCommentValue

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys[0]
    Assert-AreEqual -Expected $fieldComment -Presented $result.$itemId.$fieldId.Field.name
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$itemId.$fieldId.Value
}

function Test_EditProjectItems_Fields{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    $fieldTextName = $p.fieldtext.name ; $fieldTextId = $p.fieldtext.id
    $fieldNumberName = $p.fieldnumber.name ; $fieldNumberId = $p.fieldnumber.id
    $fieldTextValue = "new value of the comment 10.1"
    $fieldNumberValue = 42

    $fields = @{
        $fieldTextName = $fieldTextValue
        $fieldNumberName = $fieldNumberValue
    }

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Fields $fields

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-AreEqual -Expected $itemId -Presented $result.Keys[0]
    Assert-AreEqual -Expected $fieldTextValue -Presented $result.$itemId.$fieldTextId.Value
    Assert-AreEqual -Expected $fieldNumberValue -Presented $result.$itemId.$fieldNumberId.Value
}

function Test_EditProjectItems_Title_Body_AddComment{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    $newtitle = "Item 1 - title"
    $newBody = "Item 1 - body"
    $addComment = "This is a new comment added to the item."

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Title $newtitle -Body $newBody -AddComment $addComment

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-AreEqual -Expected $newtitle -Presented $result.$itemId.title.Value
    Assert-AreEqual -Expected $newBody -Presented $result.$itemId.body.Value
    Assert-AreEqual -Expected $addComment -Presented $result.$itemId.addcomment.Value
}

function Test_EditProjectItems_Status{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p -SkipItems
    $i= $p.issue ; $itemId = $i.id

    Set-ProjectHelperEnvironment -Owner $Owner -ProjectNumber $ProjectNumber

    $newStatus = "Todo"
    $statusFieldId = $p.fieldStatus.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Status $newStatus

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-AreEqual -Expected $newStatus -Presented $result.$itemId.$statusFieldId.Value
}

function Test_EditProjectItems_Status_Close{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p -SkipItems

    Set-ProjectHelperEnvironment -Owner $Owner -ProjectNumber $ProjectNumber

    $newStatus = "Done"
    $statusFieldId = $p.fieldStatus.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Close

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $newStatus -Presented $result.$itemId.$statusFieldId.Value
}

function Test_EditProjectItems_Status_Backlog{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p -SkipItems

    Set-ProjectHelperEnvironment -Owner $Owner -ProjectNumber $ProjectNumber

    $newStatus = "Todo"
    $statusFieldId = $p.fieldStatus.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Backlog

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $newStatus -Presented $result.$itemId.$statusFieldId.Value
}

function Test_EditProjectItems_Status_Ready{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p -SkipItems

    Set-ProjectHelperEnvironment -Owner $Owner -ProjectNumber $ProjectNumber

    $newStatus = "Todo"
    $statusFieldId = $p.fieldStatus.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Backlog

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $newStatus -Presented $result.$itemId.$statusFieldId.Value
}

function Test_EditProjectItems_AddCommentLongText{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p

    $commentValue = "This is a long comment added to the item. It should be added as a new comment and not override the previous one."

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"
    MockCallToString -Command ProjectHelper_EditFileCode -Outstring $commentValue

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -AddCommentLongText

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $commentValue -Presented $result.$itemId.addcomment.Value
}

function Test_EditProjectItems_BodyLongText{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p

    $commentValue = "This is a long comment added to the item. It should be added as a new comment and not override the previous one."

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"
    MockCallToString -Command ProjectHelper_EditFileCode -Outstring $commentValue

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -BodyLongText

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $commentValue -Presented $result.$itemId.body.Value
}

function Test_EditProjectItems_NormalizeTitle{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    MockCall_GetProject $p -SkipItems

    $newTitle = "[{repo}] {title}"
    $newTitle = $newTitle -replace "{repo}", $i.repositoryName
    $newTitle = $newTitle -replace "{title}", $i.title

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -NormalizeTitle

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $newTitle -Presented $result.$itemId.title.Value
}

function Test_EditProjectItems_NormalizeTitle_AlreadyNormalized{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p -Cache
    $i= $p.issue ; $itemId = $i.id

    # Already NOrmalized
    $newTitle = "[rulasg-dev-1] Issue [rulasg-dev-1] for [value between] development"
    Update-Mock_DatabaseFileWithReplace "db-$Owner-$ProjectNumber-project.json" $i.title $newTitle

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -NormalizeTitle

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $result.$itemId.Keys
}

function Test_EditProjectItems_NormalizeTitle_AlreadyNormalized_Different_Case{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p -Cache
    $i= $p.issue ; $itemId = $i.id

    # Already Normalized
    $newTitle = "[RuLasG-dev-1] Issue [rulasg-DEV-1] for [value between] development"
    $expectedtitle = "[rulasg-dev-1] Issue [rulasg-dev-1] for [value between] development"
    Update-Mock_DatabaseFileWithReplace "db-$Owner-$ProjectNumber-project.json" $i.title $newTitle

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -NormalizeTitle

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 1 -Presented $result.$itemId.Keys
    
    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
    Assert-Count -Expected 0 -Presented $result.$itemId.Keys
    Assert-AreEqual -Expected $newTitle -Presented $result.$itemId.title.Value
}

function Test_NormalizedTitle{

    Invoke-PrivateContext{
        $cases = @(
            @{item = @{Title= "Test"; repositoryName = "rulasg-dev-1"}; expected = "[rulasg-dev-1] Test"}
            @{item = @{Title= "[rulasg-dev-1] Test"; repositoryName = "rulasg-dev-1"}; expected = "[rulasg-dev-1] Test"}
            
            @{item = @{Title= "[BBVA] Test"; repositoryName = "bBva"}; expected = "[bBva] Test"}
            
            @{item = @{Title= "Test [rulasg-dev-1]"; repositoryName = "rulasg-dev-1"}; expected = "Test [rulasg-dev-1]"}
            
            @{item = @{Title= "Test [rulasg-dEv-1]"; repositoryName = "rulasg-dev-1"}; expected = "Test [rulasg-dev-1]"}

            @{item = @{Title= "[RULaSG-DeV-1] Test"; repositoryName = "rulasg-dev-1"}; expected = "[rulasg-dev-1] Test"}
            @{item = @{Title= "[RULaSG-DeV-1] Test [value between] development"; repositoryName = "rulasg-dev-1"}; `
                   expected = "[rulasg-dev-1] Test [value between] development"}
            @{item = @{Title= "[RULaSG-DeV-1] Issue [RULASG-DEV-1] for [value between] development"; repositoryName = "rulasg-dev-1"}; `
                   expected = "[rulasg-dev-1] Issue [rulasg-dev-1] for [value between] development"}
        )

        foreach($case in $cases){
            $result = Get-NormalizedTitle -Item $case.item
            Assert-AreEqual -Expected $case.expected -Presented $result
        }

    }
}

function Test_EditProjectItems_OpenInBrowser{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    # Mock the direct call for item
    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"
    MockCallToNull -Command "Invoke-ProjectHelperOpenUrl -Url ""$($i.url)"""

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -OpenInBrowser

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 0 -Presented $result
}

function Test_EditProjectItems_Force{

    # Arrange
    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    MockCall_GetProject $p
    $i= $p.issue ; $itemId = $i.id

    # Mock the direct call for item
    # MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    # for the project sync
    MockCall_GetProject $p

    # Act
    Edit-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Force

    # Assert
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 0 -Presented $result
}