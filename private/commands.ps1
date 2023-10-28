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
        [Parameter(Mandatory)][string]$CommandKey,
        [Parameter()][string]$Attributes,
        [Parameter()][string]$Repo,
        [Parameter()][string]$Title,
        [Parameter()][string]$Body,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )
    $cl = Get-CommandList

    $command = $cl.$CommandKey.Command

    if($Repo){ $command = $command -replace "{repo}",$Repo }
    if($Title){ $command = $command -replace "{title}",$Title }
    if($Body){ $command = $command -replace "{body}",$Body }
    if($Owner){ $command = $command -replace "{owner}",$Owner }
    if($ProjectNumber){ $command = $command -replace "{projectNumber}",$ProjectNumber }

    if($Attributes){ $command = $command -replace "{0}",$Attributes }

    "Build Command [$command]" | Write-Verbose

    return $command

} Export-ModuleMember -Function Build-Command

function Reset-CommandList{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope='Function')]
    
    $global:CommandList = Get-CommandListDefaults
    
} Export-ModuleMember -Function Reset-CommandList

function Get-CommandList{

    return $global:CommandList
    
} Export-ModuleMember -Function Get-CommandList

function Get-CommandListDefaults{
    $list = @{
        Version                = @{IsJson = $false ; Command = 'gh --version'}
        Issue_Create           = @{IsJson = $false ; Command = 'gh issue create --repo {repo} --title "{title}" --body "{body}"'}
        
        Project_Field_List     = @{IsJson = $false ; Command = 'gh project field-list {projectNumber} --owner {owner}'}
        Project_Item_List      = @{IsJson = $true ; Command = 'gh project item-list {projectNumber} --owner {owner} --format json'}
        Project_Item_Add       = @{IsJson = $false ; Command = 'gh project item-add {projectNumber} --owner {owner} --url {issueUrl}'}
        Project_Item_Delete    = @{IsJson = $false ; Command = 'gh project item-delete {projectNumber} --owner {owner} --id {itemId}'}
        
        Project_List           = @{IsJson = $true ; Command = 'gh project list --limit 1000 --format json'}
        Project_List_Owner     = @{IsJson = $true ; Command = 'gh project list --owner {owner} --limit 1000 --format json'}

        Project_Item_Create    = @{IsJson = $true ; Command = 'gh project item-create {projectNumber} --owner {owner} --title "{title}" --body "{body}" --format json'}
        Project_Item_Edit_Text = @{IsJson = $false ; Command = 'gh project item-edit --project-id {projectNumber} --id {1} --field-id {2} --text {3}'}
        
        Issue_List             = @{IsJson = $true ; Command = 'gh issue list --repo {repo} --json number,title,state,url'}
        
        # Repo_List              = @{IsJson = $false ; Command = 'gh repo list {owner} --limit 1000  --no-archived --source --json nameWithOwner'}
        # Repo_Edit_Add_Topic    = @{IsJson = $false ; Command = 'gh repo edit {repo} --add-topic {topics}'}
    }

    return $list
} Export-ModuleMember -Function Get-CommandListDefaults

# Call Reset-CommandList to initialize the global variable
Reset-CommandList