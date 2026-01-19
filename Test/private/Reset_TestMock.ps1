function Reset_Test_Mock{
    [cmdletbinding()]
    param(
        [switch]$NoResetDatabase
    )

    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset:$NoResetDatabase
    Mock_Today
}