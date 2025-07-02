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
    $count = $db.Staged.Values.count

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

    if($GitPromptSettings){
        "Setting Prompt with posh-git integration" | Write-Host
        if($WithNewLine){
            $GitPromptSettings.DefaultPromptBeforeSuffix.Text ='$(Get-ProjecthelperPrompt -WithNewLine)' + $GitPromptSettings.DefaultPromptBeforeSuffix.Text
        } else {
            $GitPromptSettings.DefaultPromptBeforeSuffix.Text ='$(Get-ProjecthelperPrompt)' + $GitPromptSettings.DefaultPromptBeforeSuffix.Text
        }

        $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'DarkYellow'

        return
    }

    # Default prompt setup
    "Setting Projecthelper Default Prompt" | Write-Host
    if($WithNewLine){
        $function:prompt = { "$(Get-ProjecthelperPrompt -WithNewLine) $($ExecutionContext.SessionState.Path.CurrentLocation)> " }
    } else {
        $function:prompt = { "$(Get-ProjecthelperPrompt) $($ExecutionContext.SessionState.Path.CurrentLocation)> " }
    }

} Export-ModuleMember -Function Set-ProjecthelperPrompt

