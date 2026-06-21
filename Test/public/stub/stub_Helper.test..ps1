
function Test_Invoke_StubCommand2{

    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number

    Update-Mock_Project_ReadMe_With_String_And_Config $p "Test"

    $name = "Stub_Test"

    $parameters = @{
        Str1 = 'value1'
        Bool1 = $true
        Switch1 = $true
        Hash1 = @{Key1='Value1'; Key2='Value2'}
    }

    $expectedString = "Param1: '$($Parameters.Str1)', Param2: '$($Parameters.Bool1)', Param3: '$($Parameters.Switch1)', Param4: '$($Parameters.Hash1.Keys -join ',')'"

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
    Assert-AreEqual -Expected $expectedString -Present $result
}

function Test_Stub_TestCommand2{

    $p = Get-Mock_Project_700 
    # $owner = $p.Owner; $projectNumber = $p.number

    # Update projectconfig with TestModule
    Update-Mock_Project_ReadMe_With_String_And_Config $p "Test"

    $parameters = @{
        Str1 = 'value1'
        Bool1 = $true
        Switch1 = $true
        Hash1 = @{Key1='Value1'; Key2='Value2'}
    }
    $expectedString = "Param1: '$($Parameters.Str1)', Param2: '$($Parameters.Bool1)', Param3: '$($Parameters.Switch1)', Param4: '$($Parameters.Hash1.Keys -join ',')'"

    # Actr 
    $result = Stub_TestCommand @parameters -Switch1

    ## Assert
    Assert-AreEqual -Expected $expectedString -Present $result

}