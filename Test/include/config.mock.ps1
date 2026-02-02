
# CONFIG MOCK
#
# This file is used to mock the config path and the config file
# for the tests. It creates a mock config path and a mock config file
# and sets the config path to the mock config path.
#
# THIS INCLUDE REQURED module.helper.ps1
if(-not $MODULE_NAME){ throw "Missing MODULE_NAME varaible initialization. Check for module.helerp.ps1 file." }

$MOCK_CONFIG_PATH = "test_config_path"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-{modulename}GetConfigRootPath"

function Mock_Config{
    param(
        [Parameter(Position=0)][string] $key = "config",
        [Parameter(Position=1)][object] $Config,
        [Parameter(Position=2)][string] $ModuleName,
        [Parameter(Position=3)][string] $MockPath = $MOCK_CONFIG_PATH
    )

    # Remove mock config path if exists
    if(Test-Path $MockPath){
        Remove-Item -Path $fullpath -ErrorAction SilentlyContinue -Recurse -Force
    }

    # create mock config path
    New-Item -Path $MockPath -ItemType Directory -Force

    # make full and not relative path
    $fullpath = $MockPath | Resolve-Path

    # if $config is not null save it to a file
    if($null -ne $Config){
        $configfile = Join-Path -Path $fullpath -ChildPath "$key.json"
        $Config | ConvertTo-Json -Depth 10 | Set-Content $configfile
    }

    if([string]::IsNullOrWhiteSpace($ModuleName)){
        $moduleName = $MODULE_NAME
    }

    $invokefunction = $CONFIG_INVOKE_GET_ROOT_PATH_CMD -replace "{modulename}", $moduleName

    # Mock invoke call
    MockCallToString $invokefunction -OutString $fullpath

}