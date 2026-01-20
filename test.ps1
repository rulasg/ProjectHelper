<#
.SYNOPSIS
    Run tests
.DESCRIPTION
    Run the unit test of the actual module
.NOTES
    Using TestingHelper this script will search for a Test module and run the tests
    This script will be referenced from launch.json to run the tests on VSCode
.LINK
    https://raw.githubusercontent.com/rulasg/StagingModule/main/test.ps1
.EXAMPLE
    > ./test.ps1
#>

[CmdletBinding()]
param (
    [Parameter()][switch]$ShowTestErrors,
    [Parameter()][string]$TestName
)

# Load Test_Helper module
Import-Module ./tools/Test_Helper

# Install and load TestingHelper
Import-RequiredModule "TestingHelper" -AllowPrerelease

# Install and Load Module dependencies
Get-RequiredModule | Import-RequiredModule -AllowPrerelease

# Resolve scoped tests
$TestName = [string]::IsNullOrWhiteSpace($TestName) ? $global:TestNameVar : $TestName

# Call TestingHelper to run the tests
Invoke-TestingHelper -TestName $TestName -ShowTestErrors:$ShowTestErrors

