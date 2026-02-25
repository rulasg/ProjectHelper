function Test_UserOrder_Success{
    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    $list = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -IncludeDone

    # Act
    $result = $list | Use-Order

    Assert-Count -Expected $($p.items.totalCount +4) -Presented $result

}

function Test_UserOrder_Success_GetItem_FAIL_NO_ENVIRONMENT{
    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # We need to have the environment set to get item details in PassThru
    $list = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -IncludeDone

    # Act
    $hasthorwn = $false
    try {
        $list | Use-Order 1
    } catch {
        $hasthorwn = $true
        Assert-IsTrue -Condition $_.Exception.Message.StartsWith("ProjectEnvironment is required.")
    }
    Assert-IsTrue -Condition $hasthorwn
}

function Test_UserOrder_Success_GetItem{
    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # We need to have the environment set to get item details in PassThru
    Set-ProjectHelperEnvironment -Owner $owner -ProjectNumber $projectNumber
    $list = Search-ProjectItem -IncludeDone

    # Act
    $result = $list | Use-Order 1 -PassThru

    Assert-AreEqual -Expected $($list[1].id) -Presented $result.id
}

function Test_UserOrder_Success_OpenBrowser{
    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $order = $p.issue.order ; $url = $p.issue.url

    MockCallToNull -command "Invoke-ProjectHelperOpenUrl -Url $url"

    # We need to have the environment set to get item details in PassThru
    Set-ProjectHelperEnvironment -Owner $owner -ProjectNumber $projectNumber
    $list = Search-ProjectItem -IncludeDone

    # Act
    $result = $list | Use-Order $order -OpenInBrowser

    # Assert
    Assert-IsNull -Object $result
}

function Test_UserOrder_Success_Passthru{
    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $order = $p.issue.order ; $id = $p.issue.id

    # We need to have the environment set to get item details in PassThru
    Set-ProjectHelperEnvironment -Owner $owner -ProjectNumber $projectNumber
    $list = Search-ProjectItem -IncludeDone

    # Act
    $result = $list | Use-Order $order -PassThru

    # Assert
    Assert-AreEqual -Expected $id -Presented $result.id
}
