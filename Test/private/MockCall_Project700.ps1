
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
    $project.repoFile = "invoke-repository-rulasg-dev-1.json"

    # Version of the project file modified manually to have two items with same id case sensitive
    # this is used to test case sensitivity of item ids in hashtables
    $project.projectFile_caseSensitive = "invoke-GitHubOrgProjectWithFields-octodemo-700-caseSensitive.json"
    $project.projectFile_singleItem = "invoke-GitHubOrgProjectWithFields-octodemo-700-singleItem.json"

    $content = Get-MockFileContentJson -FileName $project.projectFile
    $pActual = $content.data.organization.projectV2

    $fieldtext = $pActual.fields.nodes | Where-Object { $_.name -eq "field-text" }
    $fieldnumber = $pActual.fields.nodes | Where-Object { $_.name -eq "field-number" }
    $fielddate = $pActual.fields.nodes | Where-Object { $_.name -eq "field-date" }
    $fieldsingleselect = $pActual.fields.nodes | Where-Object { $_.name -eq "field-singleselect" }

    # Repository Info
    $repoContent = Get-MockFileContentJson -fileName $project.repofile -AsHashtable
    $project.repo = @{
        id = $repoContent.data.repository.id
        owner = $repoContent.data.repository.owner.login
        name = $repoContent.data.repository.name
        nameWithOwner = $repoContent.data.repository.nameWithOwner
        getRepoMockFile = $project.repofile
        object = $repoContent.data.repository
    }
    $project.repo.object.Remove('parent')
    $project.repo.object.owner = $repoContent.data.repository.owner.login
    
    # Project info
    $project.id = $pActual.id
    $project.owner = $pActual.owner.login
    $project.number = $pActual.number
    $project.url = $pActual.url
    $project.cacheFileName = "$($pActual.owner.login)_$($pActual.number).json"

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
    $project.items.totalCount = $pActual.items.nodes.count
    $project.items.doneCount = 6 # too complicated to read from structure

    # issueToCreateAddAndRemove
    $id = "I_kwDOPrRnkc7T2Al2"
    $itemId ="PVTI_lADOAlIw4c4BCe3VzggVZH8"
    $project.issueToCreateAddAndRemove= @{
        id = $id
        number = 46
        url = "https://github.com/octodemo/rulasg-dev-1/issues/46"
        getIssueOrPullRequestMockFile = "invoke-getissueorpullrequest-46.json"
        itemId = $itemId
        addIssueToOProjectMockFile = "invoke-additemtoproject-$($project.id)-$id.json"
        createIssueMockfile = "invoke-createissue-$($project.repo.id).json"
        removeIssueFromProjectMockFile = "invoke-removeitemfromproject-$($project.id)-$itemId.json"
    }

    # Issues to find
    $project.issueToFind = @{}
    $project.issueToFind.Ids = ($pActual.items.nodes | Where-Object { $_.content.title -eq "Issue to find" }).Id

    # Issue for developer
    $issue = $pActual.items.nodes | Where-Object { $_.content.title -eq "Issue for development" }
    $fss = $issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.issue = @{
        id                = $issue.id
        number            = $issue.content.number
        contentId         = $issue.content.id
        title             = $issue.content.title
        body              = $issue.content.body
        url               = $issue.content.url
        repositoryName    = $issue.content.repository.name
        status            = ($issue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext         = ($issue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name     = $fss.name
            optionId = ($fss.field.options | where-object { $_.name -eq $fss.name }).Id
        }
        comments          = @{
            totalCount = $issue.content.comments.totalCount
            last       = $issue.content.comments.nodes[-1]
            propertyCount = ($issue.content.comments.nodes[-1] | Get-Member -MemberType *Property).Count
        }
    }
    
    # PullRequest for developer
    $pullRequest = $pActual.items.nodes | Where-Object { $_.content.title -eq "PullRequest for development" }
    $fss = $pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.pullrequest = @{
        id                = $pullRequest.id
        contentId         = $pullRequest.content.id
        title             = $pullRequest.content.title
        repositoryName    = $pullRequest.content.repository.name
        status            = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext         = ($pullRequest.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name     = $fss.name
            optionId = ($fss.field.options | where-object { $_.name -eq $fss.name }).Id
        }
    }

    # DraftIssue for developer
    $draftIssue = $pActual.items.nodes | Where-Object { $_.content.title -eq "DraftIssue for development" }
    $fss = $draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldsingleselect.id) }
    $project.draftissue = @{
        id                = $draftIssue.id
        contentId         = $draftIssue.content.id
        title             = $draftIssue.content.title
        status            = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.name -eq "Status" }).name
        fieldtext         = ($draftIssue.fieldValues.nodes | Where-Object { $_.field.id -eq $($fieldtext.id) }).text
        fieldsingleselect = @{
            name     = $fss.name
            optionId = ($fss.field.options | where-object { $_.name -eq $fss.name }).Id
        }
    }

    # SubIssue to show
    $project.subIssueToShow = @{
        id = "PVTI_lADOAlIw4c4BCe3Vzgec8p8"
        subIssues = @(
            @{ contentId = "I_kwDOPrRnkc7KJAtI" ; title = "Set up database integration with Entity Framework Core" ; url = "https://github.com/octodemo/rulasg-dev-1/issues/8" },
            @{ contentId = "I_kwDOPrRnkc7KJQ3G" ; title = "Implement background processing with message queue" ; url = "https://github.com/octodemo/rulasg-dev-1/issues/17" },
            @{ contentId = "I_kwDOPrRnkc7KJQwB" ; title = "Implement health checks and monitoring" ; url = "https://github.com/octodemo/rulasg-dev-1/issues/14" }
        )
    }

    # SubIssue
    $project.subIssuesToAdd = $pActual.items.nodes | Where-Object { $_.content.title -like "Implement API*" } | ForEach-Object{
        @{ contentId = $_.content.Id ; url = $_.content.url ; title = $_.content.title ; addSubIssueMockfile = "invoke-addSubIssue-$($project.issue.contentId)-$($_.content.number).json" }
    }

    # Get Project with query

    $project.getProjectWithQuery = @{
        # query = "for development"
        query = 'field-text:text1'
        fieldName = "field-text"
        fieldValueActual = "text1"
        fieldValueNew = "text1_updated"
        stringToReplaceFrom = '"field-text": "text1"'
        stringToReplaceTo = '"field-text": "text1_updated"'
        getProjectWithQueryMockFile = "invoke-GitHubOrgProjectWithFields-octodemo-700-query-field-text.json"
        totalCount = 7
    }
    
    # searchIn Title like
    $project.searchInTitle = @{}
    $project.searchInTitle.titleFilter = "development"
    $project.searchInTitle.Titles = $pActual.items.nodes.content.title | Where-Object { $_ -like "*development*" }
    $project.searchInTitle.attributesDefault = @("Title", "id")
    $project.searchInTitle.attributes = @("Title", "id", "url", "Status", "field-text")

    # SearchIn FieldName
    $fieldName = "field-text"
    $fnValues = ( $pActual.items.nodes.fieldValues.nodes | Where-Object {$_.Field.Name -eq "field-text"}).text
    # $fnValues = $pActual.items.nodes | Where-Object {$_.fieldValues.nodes.text -eq "text2"}
    $project.searchInFieldName = @{}
    
    # searchIn FieldName Like
    $fn = "xt3"
    $project.searchInFieldName.Like = @{
        FieldName = $fieldName
        Filter = $fn
        Count = ($fnValues | Where-Object { $_ -like "*$fn*" }).Count
    }

    # SearchIn fieldName Exact
    $fn = "text2"
    $project.searchInFieldName.Exact = @{
        FieldName = $fieldName
        Filter = $fn
        Count = ($fnValues | Where-Object { $_ -eq $fn }).Count
    }

    # searchIn Any Field Like
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

    if ( $SkipItems ) {
        $filename = $p.projectFile_skipitems
    }
    else {
        $filename = $p.projectFile
    }

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName $filename -SkipItems:$SkipItems
    Mock_Today
 
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
    Mock_Today
 
    if ($Cache) {
        $null = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems:$SkipItems
    }
}

