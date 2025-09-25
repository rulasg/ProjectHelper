function Get-Mock_Project_625 {

    $project = @{}

    $project.projectFile = "invoke-GitHubOrgProjectWithFields-octodemo-625.json"
    $project.projectFile_skipitems = "invoke-GitHubOrgProjectWithFields-octodemo-625-skipitems.json"

    $content = Get-MockFileContentJson -FileName $project.projectFile
    $p = $content.data.organization.projectV2

    # Project info
    $project.id = $p.id
    $project.owner = $p.owner.login
    $project.number = $p.number
    $project.url = $p.url

    # Add Items to mock
    Add-ItemsToMock -project $project

    return $project

}


function Get-Mock_Project_626 {

    $project = @{}

    $project.projectFile = "invoke-GitHubOrgProjectWithFields-octodemo-626.json"
    $project.projectFile_skipitems = "invoke-GitHubOrgProjectWithFields-octodemo-626-skipitems.json"

    $content = Get-MockFileContentJson -FileName $project.projectFile
    $p = $content.data.organization.projectV2

    # Project info
    $project.id = $p.id
    $project.owner = $p.owner.login
    $project.number = $p.number
    $project.url = $p.url

    # Add Items to mock
    Add-ItemsToMock -project $project

    # Sync with 625

    $project.syncBtwPrj_625 = @{}
    $project.syncBtwPrj_625.staged = @{
        PVTI_lADOAlIw4c4A0QAozgfJYqo = @{
            PVTF_lADOAlIw4c4A0QAozgqofEM = 33
            PVTF_lADOAlIw4c4A0QAozgqoeOo = "Issue Text1 Value"
        }
        PVTI_lADOAlIw4c4A0QAozgfJYqk = @{
            PVTF_lADOAlIw4c4A0QAozgqofEM = 11
            PVTF_lADOAlIw4c4A0QAozgqoeOo = "PR Text1 Value"
        }
    }


    return $project
}

function MockCall_GetProject {
    [CmdletBinding()]
    param(
        [parameter(Position = 0)][object]$MockProject,
        [parameter()][switch]$SkipItems,
        [parameter()][switch]$Cache
    )

    $p = $MockProject ; $owner = $p.owner ; $projectNumber = $p.number

    if ( $SkipItems ) {
        $filename = $p.projectFile_skipitems
    }
    else {
        $filename = $p.projectFile
    }

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $filename -SkipItems:$SkipItems
 
    if ($Cache) {
        $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
    }
}

function Add-ItemsToMock {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)][object] $project
    )

    # Items
    $project.items = @{}
    $project.items.totalCount = $pActual.items.totalcount
    $project.items.doneCount = 6 # too complicated to read from structure

    # Issues to find
    $project.issueToFind = @{}
    $project.issueToFind.Ids = ($pActual.items.nodes | Where-Object { $_.content.title -eq "Issue to find" }).Id

    # Issue for developer
    $issue = $pActual.items.nodes | Where-Object { $_.content.title -eq "Issue for development" }
    $project.issue = @{
        id        = $issue.id
        contentId = $issue.content.id
        title     = $issue.content.title
        status    = ($issue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
    }

    # PullRequest for developer
    $pullRequest = $pActual.items.nodes | Where-Object { $_.content.title -eq "PullRequest for development" }
    $project.pullrequest = @{
        id        = $pullRequest.id
        contentId = $pullRequest.content.id
        title     = $pullRequest.content.title
        status    = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
    }

    # DraftIssue for developer
    $draftIssue = $pActual.items.nodes | Where-Object { $_.content.title -eq "DraftIssue for development" }
    $project.draftissue = @{
        id        = $draftIssue.id
        contentId = $draftIssue.content.id
        title     = $draftIssue.content.title
        status    = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        
    }
}