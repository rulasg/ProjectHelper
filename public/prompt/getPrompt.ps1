
<#
.DESCRIPTION
This file contains functions to control ProjectHelper prompt.

# ProjectHelperPromptSettings Configuration Guide
# =================================================
#
# The prompt is rendered by composing multiple segments, each defined as a
# PSCustomObject with three properties:
#   PreText          - Literal text prepended to the segment value
#   ForegroundColor  - Text color (any [ConsoleColor] name)
#   BackgroundColor  - Background color (any [ConsoleColor] name)
#
# Example output:  [github#9279 rulasg-Work&Dev ≡]
#                   │  │   │  │  │               │││
#                   │  │   │  │  │               ││└─ SpaceStatus (' ')
#                   │  │   │  │  │               │└── AfterStatus (']')
#                   │  │   │  │  │               └─── OKStatus ('≡') or KOStatus ('!' + count)
#                   │  │   │  │  └─────────────────── TitleStatus (project title)
#                   │  │   │  └────────────────────── DelimStatus2 (' ' separator)
#                   │  │   └───────────────────────── NumberStatus ('#' + project number)
#                   │  └───────────────────────────── DelimStatus1 (separator after owner)
#                   │  └───────────────────────────── OwnerStatus (owner name)
#                   └──────────────────────────────── BeforeStatus ('[')
#
# Segment render order (left to right):
#   BeforeStatus → OwnerStatus → DelimStatus1 → NumberStatus → DelimStatus2
#   → TitleStatus → DelimStatus2 → OKStatus/KOStatus → AfterStatus → SpaceStatus
#
# Segment defaults (set in Initialize-ProjectHelperPromptSettings):
#   BeforeStatus   = @{ PreText = '['  ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
#   OwnerStatus    = @{ PreText = ''   ; ForegroundColor = 'DarkCyan'    ; BackgroundColor = 'Black' }
#   DelimStatus1   = @{ PreText = ''   ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
#   NumberStatus   = @{ PreText = '#'  ; ForegroundColor = 'DarkMagenta' ; BackgroundColor = 'Black' }
#   DelimStatus2   = @{ PreText = ' '  ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
#   TitleStatus    = @{ PreText = ''   ; ForegroundColor = 'DarkGreen'   ; BackgroundColor = 'Black' }
#   SpaceStatus    = @{ PreText = ' '  ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
#   OKStatus       = @{ PreText = '≡'  ; ForegroundColor = 'Green'       ; BackgroundColor = 'Black' }
#   KOStatus       = @{ PreText = '!'  ; ForegroundColor = 'White'       ; BackgroundColor = 'Red'   }
#   AfterStatus    = @{ PreText = ']'  ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
#   NewlineStatus  = @{ PreText = '`n' ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
#
# Additional settings:
#   HidePrompt          ($false) - Set to $true to suppress the prompt entirely
#   Verbose             ($false) - Set to $true to enable verbose logging during render
#
# Dynamic values (from Get-ProjectHelperEnvironment):
#   Owner         - GitHub organization or user (shown by OwnerStatus)
#   ProjectNumber - Project number (shown by NumberStatus, prefixed with '#')
#   ProjectTitle  - Project title (shown by TitleStatus)
#
# Staged-items indicator:
#   When no items are staged  → OKStatus is used (green '≡')
#   When items are staged     → KOStatus is used (red '!' followed by the count)
#
# To customize after initialization, retrieve and modify the settings:
#   $s = Get-ProjecthelperPromptSettings
#   $s.BeforeStatus.ForegroundColor = 'Cyan'
#   $s.NumberStatus.PreText = 'No.'
#
# To re-initialize with defaults:
#   Initialize-ProjectHelperPromptSettings -Force
#
# To show/hide the prompt at runtime:
#   Show-ProjecthelperPrompt
#   Hide-ProjecthelperPrompt
#
#>

Set-MyInvokeCommandAlias -Alias ProjectHelperPromptSettingsVariableName -Command "echo ProjecthelperPromoptSettings"

function GetProjectHelperPromptSettings {

    $variable = Invoke-MyCommand -Command "ProjectHelperPromptSettingsVariableName"

    $s = Get-Variable -Name $variable -Scope Global -ErrorAction SilentlyContinue

    if($s) {
        $ret = $s.Value
    } else {
        $ret = @{}
    }

    return $ret
}

function SetProjectHelperPromptSettings($value) {
    $variable = Invoke-MyCommand -Command "ProjectHelperPromptSettingsVariableName"

    $value.Guid = (New-Guid).ToString()

    Set-Variable -Name $variable -Value $value -Scope Global

}

function Initialize-ProjectHelperPromptSettings {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    $s = GetProjectHelperPromptSettings

    if($($s.Guid) -and -not $Force) {
        Write-Verbose "ProjecthelperPromoptSettings already initialized, skipping initialization."
        return
    }

    $s = @{
        HidePrompt            = $false
        Verbose               = $false
        PreviousPromptGit     = '`n'
        ProjecthelperPrompt   = '$( $null -ne $(Get-Command -name "Write-ProjecthelperPrompt" -ErrorAction SilentlyContinue)? $(Write-ProjecthelperPrompt -WithNewLine:${withnewline}) : $null)'
        DEFAULT_PROMPT        = '$($ExecutionContext.SessionState.Path.CurrentLocation.Path)'
        DEFAULT_PROMPT_SUFFIX = '$(">" * ($nestedPromptLevel + 1))'
        BeforeStatus          = [PSCustomObject] @{ PreText = '['    ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
        DelimStatus1          = [PSCustomObject] @{ PreText = ''     ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
        DelimStatus2          = [PSCustomObject] @{ PreText = ' '    ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
        AfterStatus           = [PSCustomObject] @{ PreText = ']'    ; ForegroundColor = 'Yellow'      ; BackgroundColor = 'Black' }
        OwnerStatus           = [PSCustomObject] @{ PreText = ''     ; ForegroundColor = 'DarkCyan'    ; BackgroundColor = 'Black' }
        NumberStatus          = [PSCustomObject] @{ PreText = '#'    ; ForegroundColor = 'DarkMagenta' ; BackgroundColor = 'Black' }
        TitleStatus           = [PSCustomObject] @{ PreText = ''     ; ForegroundColor = 'DarkGreen'   ; BackgroundColor = 'Black' }
        SpaceStatus           = [PSCustomObject] @{ PreText = ' '    ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
        OKStatus              = [PSCustomObject] @{ PreText = '≡'    ; ForegroundColor = 'Green'       ; BackgroundColor = 'Black' }
        KOStatus              = [PSCustomObject] @{ PreText = '!'    ; ForegroundColor = 'white'       ; BackgroundColor = 'Red'   }
        NewlineStatus         = [PSCustomObject] @{ PreText = '`n'   ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
    }

    SetProjectHelperPromptSettings -value $s

} Export-ModuleMember -Function Initialize-ProjectHelperPromptSettings 

function Get-ProjecthelperPromptSettings {
    [CmdletBinding()]
    param()

    $s = GetProjectHelperPromptSettings

    if (-not $s.Guid) {
        Write-Verbose "ProjecthelperPromoptSettings not initialized, initializing now."
        Initialize-ProjectHelperPromptSettings
        $s = GetProjectHelperPromptSettings
    }

    return $s
}

function Write-ProjecthelperPrompt {
    [CmdletBinding()]
    param(
        [switch]$WithNewLine
    )

    $VerbosePreference = $s.Verbose ? 'Continue' : 'SilentlyContinue'

    $s = Get-ProjecthelperPromptSettings

    if ($s.HidePrompt) {
        "Prompt is hidden, returning null" | Write-Verbose
        return $null
    }

    $env = Get-ProjectHelperEnvironment

    $owner = $env.Owner
    $projectNumber = $env.ProjectNumber
    $projectTitle = $env.ProjectTitle

    "Owner : $owner" | Write-Verbose
    "ProjectNumber : $projectNumber" | Write-Verbose
    "ProjectTitle : $projectTitle" | Write-Verbose

    if (-not $owner -and -not $projectNumber) {
        return  $null
    }

    # Get Staged items
    $stagedItems = Get-ProjectItemStaged
    $countItems = $stagedItems.Count
    $countFields = $stagedItems.values.Keys.Count
    $count = "$countItems|$countFields"

    # Build prompt text

    $countColor = $countFields -eq 0 ? $s.OKStatus : $s.KOStatus
    $countText  = $countFields -eq 0 ? '' : $count

    $s.BeforeStatus       | Write-HostPrompt
    $s.OwnerStatus        | Write-HostPrompt $owner
    $s.DelimStatus1       | Write-HostPrompt
    $s.NumberStatus       | Write-HostPrompt $projectNumber
    $s.DelimStatus2       | Write-HostPrompt
    $s.TitleStatus        | Write-HostPrompt $projectTitle
    $s.DelimStatus2       | Write-HostPrompt
    $countColor           | Write-HostPrompt $countText
    $s.AfterStatus        | Write-HostPrompt
    $s.SpaceStatus        | Write-HostPrompt

    if($WithNewLine){
        $s.NewlineStatus    | Write-HostPrompt
    }

    # Write-Host $prompt -ForegroundColor $color -NoNewline:$(-Not $WithNewLine)

} Export-ModuleMember -Function Write-ProjecthelperPrompt

function Write-HostPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Text,
        [Parameter(ValueFromPipelineByPropertyName)][string]$PreText,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ForegroundColor = 'White',
        [Parameter(ValueFromPipelineByPropertyName)][string]$BackgroundColor = 'Black',
        [switch]$WithNewLine


    )
    process {
        $finalText = $PreText + $Text

        "P: $PreText" | Write-Verbose
        "T: $Text" | Write-Verbose
        "F: $ForegroundColor" | Write-Verbose
        "B: $BackgroundColor" | Write-Verbose
        "F: $finalText" | Write-Verbose

        $params = @{
            Message           = $finalText
            ForegroundColor   = $ForegroundColor
            BackgroundColor   = $BackgroundColor
            NoNewline         = $(-Not $WithNewLine)
        }

        # Default color to White if not specified
        Microsoft.PowerShell.Utility\Write-Host @params

    }
} Export-ModuleMember -Function Write-HostPrompt

function Set-ProjecthelperPrompt {
    [CmdletBinding()]
    [Alias("sphp")]
    param(
        [switch]$WithNewLine
    )

    $s = Get-ProjecthelperPromptSettings

    $ProjecthelperPrompt = $($s.ProjecthelperPrompt) -replace '{withnewline}', $WithNewLine.ToString()

    if ($GitPromptSettings) {

        # posh-gitintegration
        "GitPromptSettings found, setting up posh-git integration" | Write-Verbose

        # Save the previous prompt if not preent
        if ([string]::IsNullOrWhiteSpace($s.PreviousPromptGit)) {
            $s.PreviousPromptGit = $GitPromptSettings.DefaultPromptBeforeSuffix.Text
            "Previouse prompt git variable not found, created it with value: $($s.PreviousPromptGit)" | Write-Verbose
        }
        else {
            "Previouse prompt git variable found with value $($s.PreviousPromptGit)" | Write-Verbose
        }

        "Setting Prompt with posh-git integration" | Write-Host
        "ProjecthelperPrompt   : $ProjecthelperPrompt" | Write-Verbose
        "PreviousPromptGit     : $($s.PreviousPromptGit)" | Write-Verbose
        # Only add our prompt if it's not already there
        $GitPromptSettings.DefaultPromptBeforeSuffix.Text = $ProjecthelperPrompt + $s.PreviousPromptGit
    }
    else {

        # Default prompt setup
        "Setting Projecthelper Default Prompt" | Write-Host
        $fullDefaultPrompt = $DEFAULT_PROMPT + $prompt + $DEFAULT_PROMPT_SUFFIX
        "FUll default prompt: $fullDefaultPrompt" | Write-Verbose

        $prompt = $s.ProjecthelperPrompt -replace '{withnewline}', $WithNewLine.ToString()
        "Prompt : $prompt" | Write-Verbose
        $function:prompt = [scriptblock]::Create($prompt)
    }


} Export-ModuleMember -Function Set-ProjecthelperPrompt -Alias sphp

function Reset-ProjecthelperPrompt {
    [CmdletBinding()]
    param()

    $s = Get-ProjecthelperPromptSettings

    if ($GitPromptSettings) {

        if ($s.PreviousPromptGit) {
            "Resetting posh-git integration prompt" | Write-Host
            $GitPromptSettings.DefaultPromptBeforeSuffix.Text = $s.PreviousPromptGit
        }
        else {
            Write-Error "No previous git prompt found in environment variable ProjecthelperPromptPrevious"
        }

    }
    else {


        if (-Not [string]::IsNullOrWhiteSpace($s.DEFAULT_PROMPT)) {
            "Reset the default prompt to the original" | Write-verbose
            $newPrompt = $s.DEFAULT_PROMPT + ";" + $s.DEFAULT_PROMPT_SUFFIX
            "New Prompt: $newPrompt" | Write-Verbose
            $function:prompt = [scriptblock]::Create($newPrompt)
        }
        else {
            Write-Error "No previous default prompt found in environment variables DEFAULT_PROMPT and DEFAULT_PROMPT_SUFFIX"
        }

    }
} Export-ModuleMember -Function Reset-ProjecthelperPrompt

function Show-ProjecthelperPrompt{
    [CmdletBinding()]
    param()

    $s = GetProjecthelperPromptSettings
    $s.HidePrompt = $false
} Export-ModuleMember -Function Show-ProjecthelperPrompt

function Hide-ProjecthelperPrompt{
    [CmdletBinding()]
    param()

    $s = GetProjecthelperPromptSettings
    $s.HidePrompt = $true
} Export-ModuleMember -Function Hide-ProjecthelperPrompt

# Initialize the global variable ProjecthelperPromoptSettings if it does not exist
Initialize-ProjectHelperPromptSettings