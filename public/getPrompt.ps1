function Get-ProjecthelperPrompt{
    [CmdletBinding()]
    param(
        [switch]$WithNewLine
    )

    $env = Get-ProjectHelperEnvironment

    $owner = $env.Owner
    $projectNumber = $env.ProjectNumber

    if(-not $owner -and -not $projectNumber){
        return [string]::Empty
    }

    # Get Staged items
    $db = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber
    $count = $db.Staged.Values.Values.Count

    # Build prompt text
    $prompt = "[$owner/$projectNumber/$count]"

    if($WithNewLine){
        $prompt = "`n$prompt"
    }

    return $prompt

} Export-ModuleMember -Function Get-ProjecthelperPrompt

function Set-ProjecthelperPrompt{
    [CmdletBinding()]
    param(
        [switch]$WithNewLine
    )


    $prompt = @'
$( #PROJECTHELPER
    $testcmd = (Get-Command -name 'Get-ProjecthelperPrompt' -ErrorAction SilentlyContinue) -eq $null
    if(-not $testcmd){
        $prompt = Get-ProjecthelperPrompt -WithNewLine:${withnewline}
    } else {
        $prompt = [string]::Empty
    }
    $prompt
#PROJECTHELPER_END
)
'@

    if($GitPromptSettings){

        # Check if the prompt is already part of the DefaultPromptBeforeSuffix.Text
        if (-not $GitPromptSettings.DefaultPromptBeforeSuffix.Text.Contains('#PROJECTHELPER')) {
            "Setting Prompt with posh-git integration" | Write-Host
            $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'DarkYellow'
            $prompt = $prompt -replace '{withnewline}', $WithNewLine.ToString()
            $prompt | Write-Verbose
            # Only add our prompt if it's not already there
            $GitPromptSettings.DefaultPromptBeforeSuffix.Text = $prompt + $GitPromptSettings.DefaultPromptBeforeSuffix.Text
        }
        else {
            "ProjectHelper prompt already configured in posh-git" | Write-Host
        }

        return
    }

    # Default prompt setup
    "Setting Projecthelper Default Prompt" | Write-Host
    $prompt = '$($ExecutionContext.SessionState.Path.CurrentLocation.Path) + " " + $(Get-ProjecthelperPrompt -WithNewLine:${withnewline})'
    $prompt = $prompt -replace '{withnewline}', $WithNewLine.ToString()
    $prompt | Write-Verbose
    $function:prompt = [scriptblock]::Create($prompt)

} Export-ModuleMember -Function Set-ProjecthelperPrompt
