function Test_Invoke_StubCommandCall{

    $module = Get-ModuleRootPath | join-path -ChildPath "Test"
    $name = "Stub_Test"
    $subfuncname = "Invoke-StubCall"
    $Parameters = @{
        Str1 = 'value1'
        Bool1 = $true
        Switch1 = $true
        Hash1 = @{Key1='Value1'; Key2='Value2'}
    }
    $json = $Parameters | ConvertTo-Json
    $parametersBase64 = $json | ConvertTo-Base64
    $expectedString = "Param1: '$($Parameters.Str1)', Param2: '$($Parameters.Bool1)', Param3: '$($Parameters.Switch1)', Param4: '$($Parameters.Hash1.Keys -join ',')'"

    # Act
    $result = Invoke-StubCommandCall -Name $name -Module $module -Command $subfuncname -Parameters $parametersBase64

    # Assert
    Assert-AreEqual -Expected $expectedString -Present $result

}

function Test_Invoke_StubCommand{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number

    $module = Get-ModuleRootPath | join-path -ChildPath "Test"

    Update-Mock_Project_ReadMe_With_String_And_Config $p $module

    $name = "Stub_Test"

    $parameters = @{
        Str1 = 'value1'
        Bool1 = $true
        Switch1 = $true
        Hash1 = @{Key1='Value1'; Key2='Value2'}
    }

    Mock_InvokeStubCommandCall $name $module $parameters $true

    # Act
    $result = Invoke-PrivateContext {
        param($Arguments)

        $name = $Arguments[0]
        $owner = $Arguments[1]
        $projectNumber = $Arguments[2]
        $parameters = $Arguments[3]

        return Invoke-StubCommand -Name $name -Owner $owner -ProjectNumber $projectNumber -Parameters $parameters

    } -Arguments $name,$owner,$projectNumber,$parameters

    # Assert
    Assert-IsTrue -Condition $result
}

function Test_Stub_TestCommand{

    $p = Get-Mock_Project_700 
    # $owner = $p.Owner; $projectNumber = $p.number

    $module = Get-ModuleRootPath | join-path -ChildPath "Test"

    Update-Mock_Project_ReadMe_With_String_And_Config $p $module

    # $name = "Stub_Test"

    $parameters = @{
        Str1 = 'value1'
        Bool1 = $true
        Switch1 = $true
        Hash1 = @{Key1='Value1'; Key2='Value2'}
    }

    # Mock_InvokeStubCommandCall $name $module $parameters $true

    # Actr 
    $result = Stub_TestCommand @parameters -Switch1

    ## Assert
    Assert-IsTrue -Condition $result

}

function Stub_TestCommand{
    param(
        [Parameter(Mandatory)][string]$Str1,
        [Parameter(Mandatory)][bool]$Bool1,
        [Parameter()][switch]$Switch1,
        [Parameter()][hashtable]$Hash1
    )

    Assert-areEqual -Expected 'value1' -Present $Str1
    Assert-areEqual -Expected $true -Present $Bool1
    Assert-areEqual -Expected $true -Present $Switch1
    Assert-areEqual -Expected 'Value1' -Present $Hash1.Key1

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number
    $name = "Stub_Test"

    $parameters = [PsCustomObject] $PSBoundParameters

    Mock_InvokeStubCommandCall $name $module $parameters $true

    $result = Invoke-Privatecontext {
        param($Arguments)

        $name = $Arguments[0]
        $owner = $Arguments[1]
        $projectNumber = $Arguments[2]
        $parameters = $Arguments[3]

        $ret = Invoke-StubCommand -Name $name -Owner $owner -ProjectNumber $projectNumber -Parameters $parameters

        return $ret
    } -Arguments $name,$owner,$projectNumber,$parameters

    return $result
}