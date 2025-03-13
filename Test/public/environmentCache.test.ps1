
# Testing Environment cache
# as we do not have access to it we will use Get-ProjectItem function

function Test_EnvironmentCache{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    $fieldComment = "comment" ; $fieldTitle = "title"

    MockCall_GitHubOrgProjectWithFields_SomeOrg_164

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldTitleValue = "A draft in the project"
    $fieldCommentValue = "This"

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId
    
    Assert-AreEqual -Expected $itemId -Presented $result.id
    
    $result = Get-ProjectItem -ItemId $itemId
    Assert-AreEqual -Expected $itemId -Presented $result.id


}
