# Helper for module variables

function Find-ModuleRootPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position = 0)]
        [string]$Path
    )

    $path = Convert-Path -Path $Path

    while (-not [string]::IsNullOrWhiteSpace($Path)){
        $psd1 = Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1

        if ($psd1 | Test-Path) {

            if($psd1.BaseName -eq "Test"){
                #foudn testing module. Continue
                $path = $path | Split-Path -Parent
                continue
            }
            
            # foudn module
            return $path
        }
        # folder without psd1 file
        $path = $path | Split-Path -Parent
    }

    # Path is null. Reached driver root. Module not found
    return $null
}

$MODULE_ROOT_PATH = $PSScriptRoot | Find-ModuleRootPath
$MODULE_NAME = (Get-ChildItem -Path $MODULE_ROOT_PATH -Filter *.psd1 | Select-Object -First 1).BaseName

# Helper for module variables


$VALID_FOLDER_NAMES = @('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')

class ValidFolderNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
	  return $script:VALID_FOLDER_NAMES
    }
}

function Get-Ps1FullPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Name,
        [Parameter(Position = 1)][ValidateSet([ValidFolderNames])][string]$FolderName,
        [Parameter(Position = 0)][string]$ModuleRootPath
    )

   # If folderName is not empty
    if($FolderName -ne $null){
        $folder = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $ModuleRootPath
        $path = $folder | Join-Path -ChildPath $Name
    } else {
        $path = $Name
    }

    # Check if file exists
    if(-Not (Test-Path $path)){
        throw "File $path not found"
    }

    # Get Path item
    $item = Get-item -Path $path

    return $item
}
function Get-ModuleRootPath{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$ModuleRootPath
    )

    # if ModuleRootPath is not provided, default to local module path
    if([string]::IsNullOrWhiteSpace($ModuleRootPath)){
        $ModuleRootPath = $MODULE_ROOT_PATH
    }

    # Convert to full path
    $ModuleRootPath = Convert-Path -Path $ModuleRootPath

    return $ModuleRootPath
}

function Get-ModuleName{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$ModuleRootPath
    )

    $ModuleRootPath = Get-ModuleRootPath -ModuleRootPath $ModuleRootPath

    $MODULE_NAME = (Get-ChildItem -Path $MODULE_ROOT_PATH -Filter *.psd1 | Select-Object -First 1).BaseName


    return $MODULE_NAME
}

function Get-ModuleFolder{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][ValidateSet([ValidFolderNames])][string]$FolderName,
        [Parameter(Position = 1)][string]$ModuleRootPath
    )

    $ModuleRootPath = Get-ModuleRootPath -ModuleRootPath $ModuleRootPath

    # TestRootPath
    $testRootPath = $ModuleRootPath | Join-Path -ChildPath "Test"

    switch ($FolderName){
        'Public'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "public"
        }
        'Private'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "private"
        }
        'Include'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "include"
        }
        'TestInclude'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "include"
        }
        'TestPrivate'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "private"
        }
        'TestPublic'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "public"
        }
        'Root'{
            $moduleFolder = $ModuleRootPath
        }
        'TestRoot'{
            $moduleFolder = $testRootPath
        }
        'Tools'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "tools"
        }
        'DevContainer'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".devcontainer"
        }
        'WorkFlows'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".github/workflows"
        }
        'GitHub'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".github"
        }
        'Helper'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "helper"
        }
        'Config'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "config"
        }
        'TestHelper'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "helper"
        }
        'TestConfig'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "config"
        }
        default{
            throw "Folder [$FolderName] is unknown"
        }
    }
    return $moduleFolder
} Export-ModuleMember -Function Get-ModuleFolder