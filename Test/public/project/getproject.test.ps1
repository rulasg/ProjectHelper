function Test_GetProject_With_Query_Success{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # enable-invokeCommandAliasModule

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $query = $p.getProjectWithQuery.query
    $fileName = $p.getProjectWithQuery.getProjectWithQueryMockFile
    $totalCount = $p.getProjectWithQuery.totalCount
    $i = $p.issue
    
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -Query $query -FileName $fileName

    $result = Update-ProjectDatabase -Owner $owner -ProjectNumber $projectNumber -Query $query

    Assert-IsTrue $result

    $result = Get-Project -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected $totalCount -Presented $result.items
}

function Test_GetProject_With_Query_Success_Update{
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $cacheFileName = $p.cacheFileName
    $q = $p.getProjectWithQuery
    $fieldName = $q.FieldName
    $fieldValueActual = $q.FieldValueActual
    $fieldValueNew = $q.FieldValueNew
    $totalCount = $q.totalCount

    MockCall_GetProject $p -Cache

    # update field-text to a new value from Actual to check if it´s updated when calling Update-ProjectDatabase with a query
    Update-Mock_DatabaseFileWithReplace -Filename $cacheFileName -SearchString $q.stringToReplaceFrom -ReplaceString $q.stringToReplaceTo

    # Assert the arrangement
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueActual -Exact -IncludeDone
    Assert-Count -Expected 0 -Presented $result
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueNew -Exact -IncludeDone
    Assert-Count -Expected $totalCount -Presented $result

    # Act - Should replace new value back to actual
    $result = Update-ProjectDatabase -Owner $owner -ProjectNumber $projectNumber -Query $query

    # Assert confirm field-text value is back to actual
    Assert-IsTrue $result

    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueActual -Exact -IncludeDone
    Assert-Count -Expected $totalCount -Presented $result
}