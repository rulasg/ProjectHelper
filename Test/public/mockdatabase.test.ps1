function Test_UpdateMock_DatabaseFileWithReplace{
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

    # find "Issue for development" from database file
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueActual -Exact -IncludeDone
    Assert-Count -Expected $totalCount -Presented $result
    
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueNew -Exact -IncludeDone
    Assert-Count -Expected 0 -Presented $result

    # Add content to the title of a file
    Update-Mock_DatabaseFileWithReplace -Filename $cacheFileName -SearchString $q.stringToReplaceFrom -ReplaceString $q.stringToReplaceTo

    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueActual -Exact -IncludeDone
    Assert-Count -Expected 0 -Presented $result
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -FieldName $fieldName -Filter $fieldValueNew -Exact -IncludeDone
    Assert-Count -Expected $totalCount -Presented $result

}