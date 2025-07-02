function Test_GetProjecthelperPrompt{

    Mock_DatabaseRoot

    # No environment return null
    $result = Get-ProjecthelperPrompt
    Assert-StringIsNullOrEmpty $result

    # No environment with new line return null
    $result = Get-ProjecthelperPrompt -WithNewLine
    Assert-StringIsNullOrEmpty $result

    # Set environment with empty values
    Set-ProjectHelperEnvironment -Owner "TestOwner" -ProjectNumber "12345" -DisplayFields @("Field1", "Field2")

    # With environment return "[TestOwner/12345/0]"
    $result = Get-ProjecthelperPrompt
    Assert-AreEqual $result "[TestOwner/12345/0]"

    # With environment and new line return "[TestOwner/12345/0]`n"
    $result = Get-ProjecthelperPrompt -WithNewLine
    Assert-AreEqual $result "`n[TestOwner/12345/0]"

}