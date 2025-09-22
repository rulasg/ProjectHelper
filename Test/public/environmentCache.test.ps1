
# Testing Environment cache
# as we do not have access to it we will use Get-ProjectItem function

function Test_EnvironmentCache{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $p = Get-Mock_Project_700 ; $Owner = $p.owner ; $ProjectNumber = $p.number
    $i = $p.issue
    $f = $p.fieldtext

    $fieldComment = $f.name
    $fieldTitle = "Title"

    # Cache the project
    MockCall_GetProject_700 -Cache

    # Reset mock calls
    Reset-invokeCommandMock
    Mock_DatabaseRoot -NotReset

    $itemId = $i.Id
    $fieldTitleValue = $i.title
    $fieldCommentValue = $i.fieldtext

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId

    Assert-AreEqual -Expected $itemId -Presented $result.id

    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment

}
