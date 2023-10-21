$TESTED_MODULE_PATH = $PSScriptRoot | split-path -Parent | split-path -Parent

function ProjectHelperTest_GetPublicString{ 

    $sampleString = "this is a sample string"
    
    $result = Get-PublicString -Param1 $sampleString

    Assert-AreEqual -Expected ("Public string [{0}]" -f $samplestring) -presented $result -Comment "Sample test failed"
    
}

function ProjectHelperTest_GetPrivateString {

    $testedModulePath =  $TESTED_MODULE_PATH | Join-Path -ChildPath "ProjectHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $sampleString = "this is a sample string"
    
    $result = & $testedModule {
        $sampleString = "this is a sample string"
        Get-PrivateString -Param1 $sampleString
    }

    Assert-AreEqual -Expected ("Private string [{0}]" -f $samplestring) -presented $result -Comment "Sample test failed"
    
}

Export-ModuleMember -Function ProjectHelperTest_*
