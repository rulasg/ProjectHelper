# Quick commands

function Set-QQ_ItemId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=1)][string]$ItemId
    )

    if([string]::IsNullOrWhiteSpace($ItemId)){
        return
    }

    "Setting QQ_ItemId to $ItemId" | Write-MyDebug -Section "QuickCommand"

    Set-QQ_Previouse_ItemId $script:QQ_ItemId

    $script:QQ_ItemId = $ItemId

    Write-Host "💫" -ForegroundColor DarkYellow -NoNewline
} Export-ModuleMember -Function Set-QQ_ItemId

function Get-QQ_ItemId {
    [CmdletBinding()]
    param()

    return $script:QQ_ItemId
}

function Set-QQ_Previouse_ItemId {
    [CmdletBinding()]
    param(
        [Parameter(Position=1)][string]$ItemId
    )

    $script:QQ_Previouse_ItemId = $ItemId
}

function Get-QQ_Previouse_ItemId {
    [CmdletBinding()]
    param()

    return $script:QQ_Previouse_ItemId
}

function w ($message){
    Write-MyHost $message
}

$script:Help_Commands = @()

function New-QQ_Function {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Module,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$Alias,
        [Parameter(Mandatory)][ScriptBlock]$ScriptBlock
        )

        "Registering quick command '$Name' with alias '$Alias' for module '$Module'" | Write-MyDebug -Section "QQ_Commands"

        $findAlias = Get-Alias -Name $Alias -ErrorAction SilentlyContinue
        if($findAlias){
            Write-MyWarning "Error trying to set $Name. Alias '$Alias' already exists for command '$($findAlias.Definition)'. Please choose a different alias for the quick command '$Name'."
            return
        }
        
        new-item -path function:\ -name global:$Name -value $ScriptBlock
        Export-ModuleMember -Function $Name
        Set-Alias -Name $Alias -Value $Name -Force -Scope Global

        $script:Help_Commands += [PSCustomObject]@{
            QQ_Cmd = $Alias
            Description = $Description
            Module = $Module
        }
} Export-ModuleMember -Function New-QQ_Function

Register-QQ_Commands