
# Testing Environment cache
# as we do not have access to it we will use Get-ProjectItem function

function Test_EnvironmentCache{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    $fieldComment = "Comment" ; $fieldTitle = "Title"

    # Cache the project
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    # Reset mock calls
    Reset-invokeCommandMock
    Mock_DatabaseRoot -NotReset

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"
    $fieldTitleValue = "A draft in the project"
    $fieldCommentValue = "This"

    $result = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $itemId
    
    Assert-AreEqual -Expected $itemId -Presented $result.id

    Assert-AreEqual -Expected $fieldTitleValue -Presented $result.$fieldTitle
    Assert-AreEqual -Expected $fieldCommentValue -Presented $result.$fieldComment

}
