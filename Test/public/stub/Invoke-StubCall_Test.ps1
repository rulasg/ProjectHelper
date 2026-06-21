# function Mock_InvokeStubCommandCall($name,$module,$parameters,$result){

#     $stubCall_func = "Invoke-StubCall"

#     $parametersBase64 = $parameters | ConvertTo-Json | ConvertTo-Base64

#     $command = 'Invoke-StubCommandCall -Name {name} -Module {module} -Command {subfuncname} -ParametersBase64 {parametersbase64}'
#     $command = $command -replace "{name}", $name
#     $command = $command -replace "{module}", $module
#     $command = $command -replace "{subfuncname}", $stubCall_func
#     $command = $command -replace "{parametersbase64}", $parametersBase64
    
#     MockCallToObject -command $command -OutObject $result

# }

# 1 on the stub series
function Stub_TestCommand1{
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

    $name = "Stub_Test"
    
    $parameters = [PsCustomObject] $PSBoundParameters
    
    # This call always happen as private in ProjectHelper
    $p = Get-Mock_Project_700 ; $owner = $p.Owner; $projectNumber = $p.number
    $result = Invoke-Privatecontext {
        param($Arguments)

        $name = $Arguments[0]
        $owner = $Arguments[1]
        $projectNumber = $Arguments[2]
        $parameters = $Arguments[3]

        $ret = Invoke-StubCommand1 -Name $name -Owner $owner -ProjectNumber $projectNumber -Parameters $parameters

        return $ret
    } -Arguments $name,$owner,$projectNumber,$parameters

    return $result
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

    # This call always happen as private in ProjectHelper
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


# 5 on the stub series
function Invoke-StubCall{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $stubName,
        [Parameter(Mandatory)][hashtable] $Parameters
    )


    switch ($stubName) {
        "Stub_Test"            { $ret = Get-TestString_Parameters @Parameters }
        "Stub_GetProjectItem"  { $ret = Get-TestString_ItemId "Stub_GetProjectItem"@Parameters }
        "Stub_ShowProjectItem" { $ret = Get-TestString_ItemId "Stub_ShowProjectItem" @Parameters }
        "Stub_ShowProjectTodo" { $ret = Get-TestString "Stub_ShowProjectTodo" @Parameters }
        default { throw "Unknown stub name: $stubName" }
    }

    return $ret

} Export-ModuleMember -Function Invoke-StubCall

# 5 on the stub series
function Get-TestString_Parameters{
        param(
        [Parameter(Mandatory)][string]$Str1,
        [Parameter(Mandatory)][bool]$Bool1,
        [Parameter()][switch]$Switch1,
        [Parameter()][hashtable]$Hash1
    )

    $retString = "Param1: '$($Parameters.Str1)', Param2: '$($Parameters.Bool1)', Param3: '$($Parameters.Switch1)', Param4: '$($Parameters.Hash1.Keys -join ',')'"

    return $retString
}

function Get-TestString_ItemId{
    param([string] $StubName, [string] $ItemId)

    return "$StubName ItemId: $ItemId"
}

function Get-TestString{
    param([string] $StubName,)

    return "$StubName Get-TestString called"
}