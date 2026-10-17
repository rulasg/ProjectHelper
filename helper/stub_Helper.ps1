
# Auxiliar functions for Stub command calls

$DEFAULT_STUB_MODULE = "ProjectHelper"
$DEFAULT_STUB_API_COMMAND = "Invoke-StubCall"

# Move Flag registration to private/registerFeatureFlags.ps1 to ensure it will be registered after Register-FeatureFlag is available
# Register-FeatureFlag -key "dev_DEFAULT_STUB_MODULE" -Description "Enable development default stub module"

function Resolve-StubCommand($owner, $ProjectName, $StubName ){

    "[Resolve-StubCommand] Getting stub command for project $Owner/$ProjectNumber and StubName=$StubName >>>" | Write-MyDebug -Section "stubcall"
    
    if(Test-FeatureFlag "dev_DEFAULT_STUB_MODULE"){
        # Default stub module is $DEFAULT_STUB_MODULE that is hardcoded to ProjectHelper, Self module
        # When developing ProjectHelper is not available on the default PsPath or maybe we want to specify a different default stub module
        # This allows to point the default stub module to any path where the ProjectHelper mey be stored or any other module
        # Use Default_Stub_Module configuration to specify the path
        $c = Get-Configuration
        # $DEFAULT_STUB_MODULE = "~/code/ProjectHelper"
        $DEFAULT_STUB_MODULE = $c.Default_Stub_Module
    }

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
    [CmdletBinding()]
    param(
        #module
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter()][PsCustomObject] $Parameters
    )

    "[Invoke-StubCommand2] Calling [$name] for project [$Owner/$ProjectNumber] >>> with parameters: $($Parameters | ConvertTo-Json -Compress)" | Write-MyDebug -section "stubcall"

    # Get Module and Command
    # This function will return value falling to default if no configuration available
    $module,$command = Resolve-StubCommand $Owner $ProjectNumber $name

    $imported = Import-Module $Module -PassThru -ErrorAction SilentlyContinue
    if(-Not $imported){
        "[Invoke-StubCommand2] Module not found: $Module. Make sure the module is imported and available." | write-MyError
        return
    }

    if(-Not $imported){
        "[Invoke-StubCommand2] Module not found: $Module. Make sure the module is imported and available." | write-MyError
        return
    }

    # Calling $Command from $imported module with $parameters
    # Get the command from the specific module to avoid conflicts with other modules
    $cmd = Get-Command -Name $Command -Module $imported -ErrorAction SilentlyContinue
    if(-Not $cmd){
        "[Invoke-StubCommand2] Command [$Command] not found in module [$Module]" | write-MyError
        return
    }

    "[Invoke-StubCommand2] Calling [$name] to command [$Module/$Command] with parameters: $($parameters | ConvertTo-Json -Compress)" | Write-MyDebug -section "stubcall"
    
    $ret = & $cmd $Name $parameters

    "[Invoke-StubCommand2] Calling [$name] for project [$Owner/$ProjectNumber] <<<" | Write-MyDebug -section "stubcall"

    return $ret
}