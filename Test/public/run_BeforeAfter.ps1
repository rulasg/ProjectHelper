# Run Before and After any test
# 
# Supported by TestingHelper 4.1.0 we can specify code that will run :
# - Before each test
# - After each test
# - Before all tests
# - After all tests
#
# Move this file to public before modifying it

function Run_BeforeAll{
    Write-Verbose "Run_BeforeAll"
}

function Run_AfterAll{
    Write-Verbose "Run_AfterAll"
}

function Run_BeforeEach{
    Write-Verbose "Run_BeforeEach"

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
}

function Run_AfterEach{
    Write-Verbose "Run_AfterEach"

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule
}

Export-ModuleMember -Function Run_*
