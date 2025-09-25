
function Get-Mock_Project_700 {

    $project_700 = @{}

    $project_700.projectFile = "invoke-GitHubOrgProjectWithFields-octodemo-700.json"
    $project_700.projectFile_skipitems = "invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json"

    # Version of the project file modified manually to have two items with same id case sensitive
    # this is used to test case sensitivity of item ids in hashtables
    $project_700.projectFile_caseSensitive = "invoke-GitHubOrgProjectWithFields-octodemo-700-caseSensitive.json"

    $content = Get-MockFileContentJson -FileName $project_700.projectFile
    $p = $content.data.organization.projectV2

    $fieldtext = $p.fields.nodes | Where-Object { $_.name -eq "field-text" }
    $fieldnumber = $p.fields.nodes | Where-Object { $_.name -eq "field-number" }
    $fielddate = $p.fields.nodes | Where-Object { $_.name -eq "field-date" }
    $fieldsingleselect = $p.fields.nodes | Where-Object { $_.name -eq "field-singleselect" }

    # Project info
    $project_700.id = $p.id
    $project_700.owner = $p.owner.login
    $project_700.number = $p.number
    $project_700.url = $p.url

    # Fields info
    $project_700.fieldtext = @{ id = $fieldtext.id ; name = $fieldtext.name }
    $project_700.fieldnumber = @{ id = $fieldnumber.id ; name = $fieldnumber.name }
    $project_700.fielddate = @{ id = $fielddate.id ; name = $fielddate.name }
    $project_700.fieldsingleselect = @{ id = $fieldsingleselect.id ; name = $fieldsingleselect.name ; options = $fieldsingleselect.options }
    
    # Items
    # $project_700.$statusField = $p.fields.nodes | Where-Object { $_.name -eq "Status" }
    $project_700.items = @{}
    $project_700.items.totalCount = $p.items.totalcount
    $project_700.items.doneCount = 6 # too complicated to read from structure

    # Issues to find
    $project_700.issueToFind = @{}
    $project_700.issueToFind.Ids = ($p.items.nodes | Where-Object { $_.content.title -eq "Issue to find" }).Id

    # Issue for developer
    $issue = $p.items.nodes | Where-Object { $_.content.title -eq "Issue for development" }
    $project_700.issue = @{
        id        = $issue.id
        contentId = $issue.content.id
        title     = $issue.content.title
        status    = ($issue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
    }

    # PullRequest for developer
    $pullRequest = $p.items.nodes | Where-Object { $_.content.title -eq "PullRequest for development" }
    $project_700.pullrequest = @{
        id        = $pullRequest.id
        contentId = $pullRequest.content.id
        title     = $pullRequest.content.title
        status    = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
    }

    # DraftIssue for developer
    $draftIssue = $p.items.nodes | Where-Object { $_.content.title -eq "DraftIssue for development" }
    $project_700.draftissue = @{
        id        = $draftIssue.id
        contentId = $draftIssue.content.id
        title     = $draftIssue.content.title
        status    = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        
    }

    # Search tests
    $project_700.searchInTitle = @{}
    $project_700.searchInTitle.titleFilter = "development"
    $project_700.searchInTitle.Titles = $p.items.nodes.content.title | Where-Object { $_ -like "*development*" }
    $project_700.searchInTitle.totalCount = $project_700.searchInTitle.Titles.Count

    $project_700.searchInAnyField = @{}
    $project_700.searchInAnyField."development" = @{}
    $project_700.searchInAnyField."development".Titles = @(
        "Implement caching strategy"
        "Configure CI/CD pipeline"
        "Issue for development"
        "Create comprehensive web API setup with Node.js and Express"
        "PullRequest for development"
        "Create comprehensive .NET Web API development initialization documentation with 10 structured tasks"
        "DraftIssue for development"
        )
    $project_700.searchInAnyField."development".totalCount = $project_700.searchInAnyField."development".Titles.Count

    $project_700.searchInAnyField."96" = @{}
    $project_700.searchInAnyField."96".Titles = @(
        "Implement health checks and monitoring"
        "Implement logging and error handling"
    )
    $project_700.searchInAnyField."96".totalCount = $project_700.searchInAnyField."96".Titles.Count

    # All items except Drafts that do not have repository
    $project_700.searchInAnyField."rulasg-dev-1" = @{}
    $i = $content.data.organization.projectV2.items.nodes.content | Where-Object { $_.repository.nameWithOwner -like "$($project_700.owner)/rulasg-dev-1" }
    $project_700.searchInAnyField."rulasg-dev-1".totalCount = $i.Count
    $project_700.searchInAnyField."rulasg-dev-1".Titles = $i.title

    return $project_700
}

function MockCall_GetProject_700 {
    [CmdletBinding()]
    param(
        [parameter()][switch]$SkipItems,
        [parameter()][switch]$Cache
    )

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    if( $SkipItems ){
        $filename = $p.projectFile_skipitems
    } else {
        $filename = $p.projectFile
    }

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $filename -SkipItems:$SkipItems
 
    if ($Cache) {
        $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
    }
}

function MockCall_GetProject_700_CaseSensitive {
    [CmdletBinding()]
    param(
        # [parameter()][switch]$SkipItems,
        [parameter()][switch]$Cache
    )

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    # $filenameTag = $SkipItems ? "-skipitems" : $null
    # $filename = "invoke-GitHubOrgProjectWithFields-octodemo-700$filenameTag.json"
    $filename = $p.projectFile_caseSensitive

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $filename -SkipItems:$SkipItems
 
    if ($Cache) {
        $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
    }
}

