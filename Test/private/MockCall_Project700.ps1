
function Get-Mock_Project_700 {

    <#
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule 
    $cmd = 'Invoke-GitHubOrgProjectWithFields -Owner octodemo -ProjectNumber 700 -afterFields "" -afterItems ""'
    save-invokeAsMockFile $cmd "invoke-GitHubOrgProjectWithFields-octodemo-700.json"
    #>

    $project = @{}

    $project.projectFile = "invoke-GitHubOrgProjectWithFields-octodemo-700.json"
    $project.projectFile_skipitems = "invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems.json"
    $project.projectFile_WrongField = "invoke-GitHubOrgProjectWithFields-octodemo-700-skipitems-WrongField.json"

    # Version of the project file modified manually to have two items with same id case sensitive
    # this is used to test case sensitivity of item ids in hashtables
    $project.projectFile_caseSensitive = "invoke-GitHubOrgProjectWithFields-octodemo-700-caseSensitive.json"

    $content = Get-MockFileContentJson -FileName $project.projectFile
    $pActual = $content.data.organization.projectV2

    $fieldtext = $pActual.fields.nodes | Where-Object { $_.name -eq "field-text" }
    $fieldnumber = $pActual.fields.nodes | Where-Object { $_.name -eq "field-number" }
    $fielddate = $pActual.fields.nodes | Where-Object { $_.name -eq "field-date" }
    $fieldsingleselect = $pActual.fields.nodes | Where-Object { $_.name -eq "field-singleselect" }

    # Project info
    $project.id = $pActual.id
    $project.owner = $pActual.owner.login
    $project.number = $pActual.number
    $project.url = $pActual.url

    # Fields info
    $project.fields = @{}
    $project.fields = @{ totalCount = $pActual.fields.nodes.Count + 2 } # Extra two Content fields Body and Comments. Title is removed from Fields and added as Content Field.
    $project.fields.list = $pActual.fields.nodes | Select-Object name, datatype

    $project.fieldtext = @{ id = $fieldtext.id ; name = $fieldtext.name }
    $project.fieldnumber = @{ id = $fieldnumber.id ; name = $fieldnumber.name }
    $project.fielddate = @{ id = $fielddate.id ; name = $fielddate.name }
    $project.fieldsingleselect = @{ id = $fieldsingleselect.id ; name = $fieldsingleselect.name ; options = $fieldsingleselect.options }
    
    # Items
    $project.items = @{}
    $project.items.totalCount = $pActual.items.totalcount
    $project.items.doneCount = 6 # too complicated to read from structure

    # Issues to find
    $project.issueToFind = @{}
    $project.issueToFind.Ids = ($pActual.items.nodes | Where-Object { $_.content.title -eq "Issue to find" }).Id

    # Issue for developer
    $issue = $pActual.items.nodes | Where-Object { $_.content.title -eq "Issue for development" }
    $fss = $issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.issue = @{
        id        = $issue.id
        contentId = $issue.content.id
        title     = $issue.content.title
        repositoryName = $issue.content.repository.name
        status    = ($issue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name = $fss.name
            optionId = ($fss.field.options | where-object {$_.name -eq $fss.name}).Id
        }
    }

    # PullRequest for developer
    $pullRequest = $pActual.items.nodes | Where-Object { $_.content.title -eq "PullRequest for development" }
    $fss = $pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.pullrequest = @{
        id        = $pullRequest.id
        contentId = $pullRequest.content.id
        title     = $pullRequest.content.title
        repositoryName = $pullRequest.content.repository.name
        status    = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name = $fss.name
            optionId = ($fss.field.options | where-object {$_.name -eq $fss.name}).Id
        }
    }

    # DraftIssue for developer
    $draftIssue = $pActual.items.nodes | Where-Object { $_.content.title -eq "DraftIssue for development" }
    $fss = $draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.draftissue = @{
        id        = $draftIssue.id
        contentId = $draftIssue.content.id
        title     = $draftIssue.content.title
        status    = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name = $fss.name
            optionId = ($fss.field.options | where-object {$_.name -eq $fss.name}).Id
        }
    }

    # Search tests
    $project.searchInTitle = @{}
    $project.searchInTitle.titleFilter = "development"
    $project.searchInTitle.Titles = $pActual.items.nodes.content.title | Where-Object { $_ -like "*development*" }
    $project.searchInTitle.attributesDefault = @("Title","id")
    $project.searchInTitle.attributes = @("Title","id","url","Status","field-text")

    $project.searchInAnyField = @{}
    $project.searchInAnyField."development" = @{}
    $project.searchInAnyField."development".Titles = @(
        "Implement caching strategy"
        "Configure CI/CD pipeline"
        "Issue for development"
        "Create comprehensive web API setup with Node.js and Express"
        "PullRequest for development"
        "Create comprehensive .NET Web API development initialization documentation with 10 structured tasks"
        "DraftIssue for development"
        )
    $project.searchInAnyField."development".totalCount = $project.searchInAnyField."development".Titles.Count

    $project.searchInAnyField."96" = @{}
    $project.searchInAnyField."96".Titles = @(
        "Implement health checks and monitoring"
        "Implement logging and error handling"
    )
    $project.searchInAnyField."96".totalCount = $project.searchInAnyField."96".Titles.Count

    # All items except Drafts that do not have repository
    $project.searchInAnyField."rulasg-dev-1" = @{}
    $i = $content.data.organization.projectV2.items.nodes.content | Where-Object { $_.repository.name -like "rulasg-dev-1" }
    $project.searchInAnyField."rulasg-dev-1".totalCount = $i.Count
    $project.searchInAnyField."rulasg-dev-1".Titles = $i.title

    return $project
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

