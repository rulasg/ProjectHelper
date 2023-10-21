

function Invoke-GhExpression{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Command
    )

    # $commandScript = [scriptblock]::Create($Command)
    # Invoke-command -ScriptBlock $commandScript
    $ret = $null

    $Command | Write-Information

    if ($PSCmdlet.ShouldProcess("GH Command", $Command)) {
        $ret = Invoke-Expression -Command $Command
    }

    return $ret
}

function Invoke-GhExpressionToJson{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Command
    )

    $result = Invoke-GhExpression -Command $Command

    $ret = $null -eq $result ? '[]' : $result | ConvertFrom-Json

    return $ret
}

# GHRepoListJson

$script:SCRIPTBLOCK_INVOKE_GH_REPO_LIST_JSON = {
    $ret = gh repo list --json $JsonAttributes
    return $ret
}

function script:Invoke-GHRepoListJson{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$JsonAttributes,
        [Parameter()][string]$Owner,
        [Parameter()][string]$Topic

        # owner

    )

    # $ret = Invoke-Command -ScriptBlock $script:SCRIPTBLOCK_INVOKE_GH_REPO_LIST_JSON
    # return $ret

    $command = "gh repo list" 

    if($Owner){
        $command += " $Owner"
    }

    $command += " --limit 1000  --no-archived --source --json $JsonAttributes"

    if ($Topic) {
        $command += " --topic $Topic"
    }

    Invoke-GhExpression -Command $command

}

function script:Invoke-InjectDependencyINVOKE_GH_REPO_LIST_JSON{
    [CmdletBinding()]
    param(
        #ScriptBlockToInject
        [Parameter(ValueFromPipeline)][ScriptBlock] $ScriptBlockToInject
    )

    $script:SCRIPTBLOCK_INVOKE_GH_REPO_LIST_JSON = $ScriptBlockToInject
} 


# GhRepoEditWithTopics

function script:Invoke-GhRepoEditWithTopics{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Topic
    )

    
    gh repo edit $Repo --add-topic $topic
}
