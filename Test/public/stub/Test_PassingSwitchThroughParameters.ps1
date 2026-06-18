function Test_PassingSwitchThroughParameters{

    $str1 = "TestString"
    $switch1 = $false
    $switch2 = $true
    $number1 = 5
    $hash1 = @{Key1='kk1'; Key2='VV2'}

    # Act
    $result = Func1 -Str1 $str1 -Switch2 $switch2 -Number1 $number1 -Hash1 $hash1

    # Assert
    Assert-areEqual -Expected "Str1: $str1, Switch1: $switch1, Switch2: $switch2, Number1: $number1, Hash1: @{Key1=$($hash1.Key1); Key2=$($hash1.Key2)}" -Present $result
}

# Stub_ShowProjectItem
function Func1{
    param(
        [string]$Str1,
        [switch]$Switch1,
        [switch]$Switch2,
        [int]$Number1,
        [hashtable]$Hash1
    )

    $parameters = [pscustomobject] $PSBoundParameters

    $result = Func2 -Parameters $parameters

    return $result
}

#Invoke-StubCommand
function Func2{
    param(
        [Parameter(Mandatory)][pscustomobject] $Parameters
    )

    # Transformation to avoid lossing data on type tranlation
    # Loop through properties and assign bool to all switch type variables
    $ht = $Parameters.PsObject.BaseObject
    foreach($key in $ht.Keys){
        switch($ht.$key.GetType()){
            "switch" { $ht.$key = $ht.$key.IsPresent }
        }
    }

    # Prepare parameters for call
    $json = $Parameters | ConvertTo-Json
    $paramsbase64 = $json | ConvertTo-Base64

    $result = Func3 -ParametersBase64 $paramsbase64

    return $result
}

########## InvokeHelper call

#Invoke-StubCommandCall
function Func3 {
    param(
        [Parameter(Mandatory)][string] $ParametersBase64

    )

    $parameters = $ParametersBase64 | ConvertFrom-Base64 | ConvertFrom-Json -AsHashtable

    $result = Func4 @parameters

    return $result
}

#Invoke-Stub
function Func4{
    param(
        [Parameter(Mandatory)][string]$Str1,
        [Parameter()][switch]$Switch1,
        [Parameter()][switch]$Switch2,
        [Parameter()][int]$Number1,
        [Parameter()][hashtable]$Hash1
    )

    $ret = "Str1: $Str1, Switch1: $Switch1, Switch2: $Switch2, Number1: $Number1, Hash1: @{Key1=$($Hash1.Key1); Key2=$($Hash1.Key2)}"

    return $ret
}
