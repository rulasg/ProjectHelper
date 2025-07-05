
$global:ProjecthelperPromoptSettings = $global:ProjecthelperPromoptSettings ?? @{
    Guid                  = (New-Guid).ToString()
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
    SpaceStatus           = [PSCustomObject] @{ PreText = ' '    ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
    OKStatus              = [PSCustomObject] @{ PreText = '≡'    ; ForegroundColor = 'Green'       ; BackgroundColor = 'Black' }
    KOStatus              = [PSCustomObject] @{ PreText = '!'    ; ForegroundColor = 'white'       ; BackgroundColor = 'Red'   }
    NewlineStatus         = [PSCustomObject] @{ PreText = '`n'   ; ForegroundColor = 'Black'       ; BackgroundColor = 'Black' }
}


function Write-ProjecthelperPrompt {
    [CmdletBinding()]
    param(
        [switch]$WithNewLine
    )

    $VerbosePreference = $s.Verbose ? 'Continue' : 'SilentlyContinue'

    $s = $ProjecthelperPromoptSettings

    if ($s.HidePrompt) {
        "Prompt is hidden, returning null" | Write-Verbose
        return $null
    }

    "hola" | Write-Verbose

    $env = Get-ProjectHelperEnvironment

    $owner = $env.Owner
    $projectNumber = $env.ProjectNumber

    "Owner : $owner" | Write-Verbose
    "ProjectNumber : $projectNumber" | Write-Verbose

    if (-not $owner -and -not $projectNumber) {
        return  $null
    }

    # Get Staged items
    $stagedItems = Get-ProjectItemStaged
    $count = $stagedItems.Values.Values.Count

    # Build prompt text

    $countColor = $count -eq 0 ? $s.OKStatus : $s.KOStatus
    $countText  = $count -eq 0 ? '' : $count

    $s.BeforeStatus       | Write-HostPrompt
    $s.OwnerStatus        | Write-HostPrompt $owner
    $s.DelimStatus1       | Write-HostPrompt
    $s.NumberStatus       | Write-HostPrompt $projectNumber
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
        Write-Host @params

    }
} Export-ModuleMember -Function Write-HostPrompt

function Set-ProjecthelperPrompt {
    [CmdletBinding()]
    param(
        [switch]$WithNewLine
    )

    $s = $ProjecthelperPromoptSettings

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
            $s.PreviousPromptGit = $s.PreviousPromptGit
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


} Export-ModuleMember -Function Set-ProjecthelperPrompt

function Reset-ProjecthelperPrompt {
    [CmdletBinding()]
    param()

    $s = $ProjecthelperPromoptSettings

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

    $s = $ProjecthelperPromoptSettings
    $s.HidePrompt = $false
} Export-ModuleMember -Function Show-ProjecthelperPrompt

function Hide-ProjecthelperPrompt{
    [CmdletBinding()]
    param()

    $s = $ProjecthelperPromoptSettings
    $s.HidePrompt = $true
} Export-ModuleMember -Function Hide-ProjecthelperPrompt
