function Test_InvokeAddBlockedBy_SUCCESS {
    # Arrange
    Reset-InvokeCommandMock

    # Act
    $request = Invoke-PrivateContext {
        function Invoke-GraphQL {
            param($Query, $Variables)
            return @{ Query = $Query; Variables = $Variables }
        }

        Invoke-AddBlockedBy -IssueId I_blocked -BlockingIssueId I_blocker
    } -ModulePath (Get-Module ProjectHelper).Path

    # Assert
    Assert-AreEqual -Expected "I_blocked" -Presented $request.Variables.input.issueId
    Assert-AreEqual -Expected "I_blocker" -Presented $request.Variables.input.blockingIssueId
    Assert-IsTrue -Condition ($request.Query.Contains('addBlockedBy(input: $input)'))
    Assert-IsTrue -Condition ($request.Query.Contains('AddBlockedByInput!'))
}
