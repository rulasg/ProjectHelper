
function Get-Mock_Project_700 {

    $content = Get-MockFileContentJson -FileName "invoke-GitHubOrgProjectWithFields-octodemo-700.json"
    $p = $content.data.organization.projectV2

    $fieldtext = $p.fields.nodes | Where-Object { $_.name -eq "field-text" }
    $fieldnumber = $p.fields.nodes | Where-Object { $_.name -eq "field-number" }
    $fielddate = $p.fields.nodes | Where-Object { $_.name -eq "field-date" }

    $issue = $p.items.nodes | Where-Object { $_.content.title -eq "Issue for development" }
    $pullRequest = $p.items.nodes | Where-Object { $_.content.title -eq "PullRequest for development" }
    $draftIssue = $p.items.nodes | Where-Object { $_.content.title -eq "DraftIssue for development" }

    $project_700 = @{
        id = $p.id
        owner = $p.owner.login
        number = $p.number
        url = $p.url
        fieldtext = @{ id = $fieldtext.id ; name = $fieldtext.name }
        fieldnumber = @{ id = $fieldnumber.id ; name = $fieldnumber.name }
        fielddate = @{ id = $fielddate.id ; name = $fielddate.name }
        issue = @{
            id = $issue.id
            contentId = $issue.content.id
            title = $issue.content.title
            fieldtext = ($issue.fieldValues.nodes | Where-Object {$_.field.id -eq $($fieldtext.id)}).text
        }
        pullrequest = @{
            id = $pullRequest.id
            contentId = $pullRequest.content.id
            title = $pullRequest.content.title
            fieldtext = ($pullRequest.fieldValues.nodes | Where-Object {$_.field.id -eq $($fieldtext.id)}).text
        }
        draftissue = @{
            id = $draftIssue.id
            contentId = $draftIssue.content.id
            title = $draftIssue.content.title
            fieldtext = ($draftIssue.fieldValues.nodes | Where-Object {$_.field.id -eq $($fieldtext.id)}).text
        }
    }

    return $project_700
}

$PROJECT_700 = Get-Mock_Project_700

function MockCall_GitHubOrgProjectWithFields_700{
    [CmdletBinding()]
    param(
        [parameter()][switch]$SkipItems,
        [parameter()][switch]$Cache
    )
    $owner = "octodemo"
    $projectNumber = "700"
    $filenameTag = $SkipItems ? "-skipitems" : $null
    $filename = "invoke-GitHubOrgProjectWithFields-octodemo-700$filenameTag.json"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $filename -SkipItems:$SkipItems
 
    if($Cache){
        $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
    }

}

function MockCall_GitHubOrgProjectWithFields{
    Param(
        [string]$Owner,
        [string]$ProjectNumber,
        [string]$FileName,
        [switch]$SkipItems
    )

    $cmdName = $SkipItems ? "GitHubOrgProjectWithFieldsSkipItems" : "GitHubOrgProjectWithFields"

    $cmd = ((Get-InvokeCommandAliasList).$cmdName).Command
    $cmd = $cmd -replace '{owner}', $Owner
    $cmd = $cmd -replace '{projectnumber}', $ProjectNumber
    $cmd = $cmd -replace '{afterFields}', ""
    $cmd = $cmd -replace '{afterItems}', ""

    # Check if filename contains "skipitems" and throw error if it doesn't
    if ( $SkipItems -and $FileName -notlike '*skipitems*') {
        throw "Filename must contain 'skipitems'. Please rename the file or use a different file."
    }

    MockCallJson -Command $cmd -Filename $FileName
}

function MockCall_GitHubOrgProjectWithFields_Null{
    Param(
        [string]$Owner,
        [string]$ProjectNumber
    )

    $cmd = ((Get-InvokeCommandAliasList)."GitHubOrgProjectWithFields").Command
    $cmd = $cmd -replace '{owner}', $Owner
    $cmd = $cmd -replace '{projectnumber}', $ProjectNumber
    $cmd = $cmd -replace '{afterFields}', ""
    $cmd = $cmd -replace '{afterItems}', ""

    MockCalltoNull -Command $cmd
}