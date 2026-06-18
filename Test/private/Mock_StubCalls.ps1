function Mock_InvokeStubCommandCall($name,$module,$parameters,$result){

    $stubCall_func = "Invoke-StubCall"

    $parametersBase64 = $parameters | ConvertTo-Json | ConvertTo-Base64

    $command = 'Invoke-StubCommandCall -Name {name} -Module {module} -Command {subfuncname} -ParametersBase64 {parametersbase64}'
    $command = $command -replace "{name}", $name
    $command = $command -replace "{module}", $module
    $command = $command -replace "{subfuncname}", $stubCall_func
    $command = $command -replace "{parametersbase64}", $parametersBase64
    
    MockCallToObject -command $command -OutObject $result

}