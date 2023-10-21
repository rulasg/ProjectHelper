# Description: This file contains the commands used to interact with GitHub throw the CLI


<#
.SYNOPSIS
    Build a command using the global CommandList variable
.DESCRIPTION
    This function will obtain the command tht later should execute Invoke-GhExpression
    To testing you can change the value of the $global:CommandList variable to mock the call 
    to the gh cli and therefore GitHub.
#>
function Build-Command{
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory, Position = 0)][string]$GhCommandKey,
        [Parameter(Position = 1)][string]$Parameter0,
        [Parameter(Position = 2)][string]$Parameter1,
        [Parameter(Position = 3)][string]$Parameter2
    )

    $expression = $global:CommandList.$GhCommandKey

    $ret = $expression -f $Parameter0,$Parameter1,$Parameter3

    return $ret
} Export-ModuleMember -Function Build-Command

function Build-Command2{
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory)][string]$CommandKey,
        [Parameter()][string]$Attributes,
        [Parameter()][string]$Repo,
        [Parameter()][string]$Title,
        [Parameter()][string]$Body
    )

    $command = $global:CommandList.$CommandKey

    if($Repo){ $command = $command -replace "{repo}",$Repo }
    if($Title){ $command = $command -replace "{title}",$Title }
    if($Body){ $command = $command -replace "{body}",$Body }

    if($Attributes){ $command = $command -replace "{0}",$Attributes }

    "Build Command [$command]" | Write-Verbose

    return $command

} Export-ModuleMember -Function Build-Command

function Reset-CommandList{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]

    $global:CommandList = @{
        Version                = 'gh --version'
        Issue_Create           = 'gh issue create --repo "{repo}" --title "{title}" --body "{body}"'
        Issue_List             = 'gh issue list --repo {repo} --json number,title,state,url'
        Project_Field_List     = 'gh project field-list {0} --owner {1}'
        Project_Item_List      = 'gh project item-list {0} --owner "{1}"'
        Project_Item_Add       = 'gh project item-add {0} --owner {1} --url {2}'
        Project_Item_Delete    = 'gh project item-delete {0} --owner $owner --id {1}'
        Project_Item_Edit_Text = 'gh project item-edit --project-id {0} --id {1} --field-id {2} --text {3}'
        Project_Item_Create    = 'gh project item-create {0} --owner "{1}" --title "{2}" --body "{3}"'
        Project_List           = 'gh project list --owner "{0}" --limit 1000 --format json'
        Repo_List              = 'gh repo list {0} --limit 1000  --no-archived --source --json {1}"'
        Repo_Edit_Add_Topic    = 'gh repo edit {0} --add-topic {1}'
    }
}

Reset-CommandList

