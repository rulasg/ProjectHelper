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
        $prompt = "$prompt`n"
    }

    return $prompt

} Export-ModuleMember -Function Get-ProjecthelperPrompt

function Set-ProjecthelperPrompt{
    [CmdletBinding()]
    param()

    if($GitPromptSettings){
        "Setting Prompt with posh-git integration" | Write-Host
        $GitPromptSettings.DefaultPromptBeforeSuffix.Text ='`n$(Get-ProjecthelperPrompt -WithNewLine)'
        $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'Red'
        return
    }

    # Default prompt setup
    "Setting Default Prompt" | Write-Host
    $function:prompt = { "$(Get-ProjecthelperPrompt) $($ExecutionContext.SessionState.Path.CurrentLocation)> " }

} Export-ModuleMember -Function Set-ProjecthelperPrompt

