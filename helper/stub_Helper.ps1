
# Auxiliar functions for Stub command calls

Set-MyInvokeCommandAlias -Alias "InvokeStub" -Command 'Invoke-StubCommandCall -Name {name} -Module {module} -Command {command} -ParametersBase64 {parametersbase64}'

$DEFAULT_STUB_MODULE = "ProjectHelper"
$DEFAULT_STUB_API_COMMAND = "Invoke-StubCall"

function Resolve-StubCommand($owner, $ProjectName, $StubName ){

    "[Resolve-StubCommand] Getting stub command for project $Owner/$ProjectNumber and StubName=$StubName >>>" | Write-MyDebug -Section "stubcall"
    
    # Get project config
    $config = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber
    $command = $config.stubcommand ?? $DEFAULT_STUB_API_COMMAND
    $module = $config.module ?? $DEFAULT_STUB_MODULE
    
    # Test StubCommand
    # Check if module has function to call StubName
    $isExist = Test-StubCommand $module $command
    if(-not $isExist){
        $module = $DEFAULT_STUB_MODULE
        $command = $DEFAULT_STUB_API_COMMAND
    }
    
    "[Resolve-StubCommand] Getting stub command for project $Owner/$ProjectNumber and StubName=$StubName <<< - Module=$module, Command=$command" | Write-MyDebug -Section "stubcall"
    return $module, $command
}

function Get-StubModuleFromProject($owner, $projectNumber){

    $config = Get-ProjectConfig -Owner $owner -ProjectNumber $projectNumber

    if([string]::IsNullOrWhiteSpace($config.module)){
        "[Get-StubModuleFromProject] No Module found in project configuration for project $Owner/$ProjectNumber . Default to [$DEFAULT_STUB_MODULE]" | Write-MyDebug -section "stubcall"
        $module = $DEFAULT_STUB_MODULE
    } else {
        "[Get-StubModuleFromProject] Module found in project configuration for project $Owner/$ProjectNumber : $($config.module)" | Write-MyDebug -section "stubcall"
        $module = $config.module
    }

    return $module
}

function Register-StubCommand($Name,$Description){

    $script:StubRecord = $script:StubRecord ?? @{}

    $script:StubRecord[$Name] = $Description
}

function Get-ProjectHelperStubCommand($Name){

    # Return the full list
    if([string]::IsNullOrWhiteSpace($Name)){
        return $script:StubRecord
    }

    # Return the value. $null if not found
    if($script:StubRecord.ContainsKey($Name)){
        return $script:StubRecord[$Name]
    }
} Export-ModuleMember -Function Get-ProjectHelperStubCommand

function Test-StubCommand($module, $command){

    # Check if target command is availabele in loaded modules
    # TODO: Improve this logic to allow avaialbe modules
    $m = Import-Module $module -PassThru -ErrorAction SilentlyContinue
    if(-Not $m){
        "[Test-StubCommand] NOT found Module [$Module]" | Write-MyDebug -section "stubcall"
        return $false
    }

    $cmd = Get-Command -Module $m -Name $Command -ErrorAction SilentlyContinue

    if(-Not $cmd){
        "[Test-StubCommand] NOT found [$Command] in Module [$Module]" | Write-MyDebug -section "stubcall"
        return $false
    }

    "[Test-StubCommand] Found [$Command] in Module [$Module]" | Write-MyDebug -section "stubcall"
    return $true
}

function Invoke-StubCommand{
    param(
        #module
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter()][PsCustomObject] $Parameters
    )

    "[Invoke-StubCommand] Calling [$name] for project $Owner/$ProjectNumber" | Write-MyDebug -section "stubcall" -Object $Parameters

    # Get Module and Command
    # This function will return value falling to default if no configuration available
    $module,$command = Resolve-StubCommand $Owner $ProjectNumber $name

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

    $params = @{
        name = $Name
        module = $module
        command = $command
        parametersbase64 = $paramsbase64
    }

    $ret = Invoke-MyCommand -Command "InvokeStub" -Parameters $params

    return $ret
}

function Invoke-StubCommandCall {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Module,
        [Parameter(Mandatory)][string]$Command,
        #scriptblock to invoke within the module
        [Parameter()][string]$ParametersBase64
    )

    $imported = Import-Module $Module -PassThru -ErrorAction SilentlyContinue
    if(-Not $imported){
        "[Invoke-StubCommandCall] Module not found: $Module. Make sure the module is imported and available." | write-MyError
        return
    }

    $parameters = $ParametersBase64 | ConvertFrom-Base64 | ConvertFrom-Json -AsHashtable

    if(-Not $imported){
        "[Invoke-StubCommandCall] Module not found: $Module. Make sure the module is imported and available." | write-MyError
        return
    }

    # Calling $Command from $imported module with $parameters
    # Get the command from the specific module to avoid conflicts with other modules
    $cmd = Get-Command -Name $Command -Module $imported -ErrorAction SilentlyContinue
    if(-Not $cmd){
        "[Invoke-StubCommandCall] Command [$Command] not found in module [$Module]" | write-MyError
        return
    }

    "[Invoke-StubCommandCall] Calling [$Command] from module [$Module] with parameters: $($parameters | ConvertTo-Json -Compress)" | Write-MyDebug -section "stubcall"
    
    $ret = & $cmd $Name $parameters

    return $ret
} Export-ModuleMember -Function Invoke-StubCommandCall