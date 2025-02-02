# function Test_MockTest_SUCCESS{

#     Reset-InvokeCommandMock
#     Initialize-DatabaseRoot

#     ## Throw with no mock
#     # throw if you do not mock the call on testing
#     $hasThrown = $false
#     try {
#         $result = Get-HelloWorld
#     }
#     catch {
#         $hasThrown = $true
#     }
#     Assert-IsTrue -Condition $hasThrown

#     # Mock the call
#     MockCallToString -Command 'echo "Hello World"' -OutString "Mocked Hello World"
#     $result = Get-HelloWorld
#     Assert-AreEqual -Expected "Mocked Hello World" -Presented $result

#     # Real call
#     Reset-InvokeCommandMock
#     # Enable to allow to invoke not mocked
#     Enable-InvokeCommandAlias -tag ProjectHelperModule
#     $result = Get-HelloWorld
#     Assert-AreEqual -Expected "Hello World" -Presented $result
#     Disable-InvokeCommandAlias -Tag ProjectHelperModule

# }