function Test_GetProjectTodo_Default{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number

    MockCall_GetProject $p -Cache
    MockCall_GetProject $p -SkipItems

    # Act
    $result = Get-ProjectItemTodo -Owner $owner -ProjectNumber $projectNumber

    # Assert
    Assert-Count -Expected 7 -Presented $result

    # Assert all status is "In Progress"
    Assert-areEqual -Expected "In Progress" -Presented $($result | Select-Object -ExpandProperty Status -Unique)

    # TODO: Assert sort bu duedate
    # TODO: Assert sort bu updatedAt

}

function Test_GetProjectTodo_Status{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number

    MockCall_GetProject $p -Cache
    MockCall_GetProject $p -SkipItems

    # Act
    $result = Get-ProjectItemTodo -Owner $owner -ProjectNumber $projectNumber -Status "Todo","In Progress"

    # Assert
    Assert-Count -Expected 19 -Presented $result

    # Assert sorted by Status
    0..6 | foreach-object{ Assert-AreEqual -Expected "In Progress" -Presented $result[$_].Status}
    7..18 | foreach-object{ Assert-AreEqual -Expected "Todo" -Presented $result[$_].Status}

    # TODO: Assert sort bu duedate
    # TODO: Assert sort bu updatedAt

}

function Test_ShowProjectTodo_Default{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number
    # show will return format objects.
    $count = $p.getprojectItemTodo.allCount + 4

    MockCall_GetProject $p -Cache
    MockCall_GetProject $p -SkipItems

    # Act
    $result = Show-BaseProjectTodo -Owner $owner -ProjectNumber $projectNumber

    # Assert
    Assert-Count -Expected $count -Presented $result

    # TODO: trace host output and check content
}

function Test_ShowProjectTodo_Passthru{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number
    $status = $p.getprojectItemTodo.statusTodo

    MockCall_GetProject $p -Cache
    MockCall_GetProject $p -SkipItems

    # Act
    $result = Show-BaseProjectTodo -Owner $owner -ProjectNumber $projectNumber -Passthru

    # Assert
    Assert-areEqual -Expected "In Progress" -Presented $($result | Select-Object -ExpandProperty Status -Unique)

    # Assert all status is "In Progress"
    $result.Status | ForEach-Object{ Assert-Contains -Expected $status -Presented $_ }

    # TODO: Assert sort bu duedate
    # TODO: Assert sort bu updatedAt

}

function Test_ShowProjectTodo_MaxNumber{

    $maxNumber = 3

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number
    $allCount = $p.getprojectItemTodo.allCount


    MockCall_GetProject $p -Cache
    MockCall_GetProject $p -SkipItems

    # Act
    $result = Show-BaseProjectTodo -Owner $owner -ProjectNumber $projectNumber -Passthru -MaxNumber $maxNumber
    
    # Assert
    Assert-Count -Expected $maxNumber -Presented $result
    
    # Act
    $result = Show-BaseProjectTodo -Owner $owner -ProjectNumber $projectNumber -Passthru -MaxNumber $maxNumber -All

    # Assert
    Assert-Count -Expected $allCount -Presented $result

}

function Test_ShowProjectTodo_Ordinal{

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.Number
    $ordinal = $p.getprojectItemTodo.ordinal
    $itemId = $p.getprojectItemTodo.itemId

    # Mock Project readme for config
    Update-Mock_Project_ReadMe_With_String_And_Config $p "Test"

    # Act
    $result = Show-BaseProjectTodo -Owner $owner -ProjectNumber $projectNumber -Ordinal $ordinal
    
    # Assert
    Assert-AreEqual -Expected "ItemId: $ItemId" -Presented $result

}
