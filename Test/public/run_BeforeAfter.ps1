# Run Before and After any test
#
# Supported by TestingHelper 4.1.0 we can specify code that will run :
# - Before each test
# - After each test
# - Before all tests
# - After all tests

function Run_BeforeAll{
    Write-Verbose "Run_BeforeAll"
}

function Run_AfterAll{
    Write-Verbose "Run_AfterAll"
}

function Run_BeforeEach{
    Write-Verbose "Run_BeforeEach"
}

function Run_AfterEach{
    Write-Verbose "Run_AfterEach"
}

Export-ModuleMember -Function Run_*
