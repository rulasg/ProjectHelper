function Get-Mock_Project_625 {

    $project = @{}

    <#
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule 
    $cmd = 'Invoke-GitHubOrgProjectWithFields -Owner octodemo -ProjectNumber 625 -afterFields "" -afterItems ""'
    save-invokeAsMockFile $cmd "invoke-GitHubOrgProjectWithFields-octodemo-625.json"
    #>

    $name = "invoke-GitHubOrgProjectWithFields-octodemo-625"
    $project.projectFile = $name + ".json"
    $project.projectFile_skipitems = $name + "-skipitems.json"

    $content = Get-MockFileContentJson -FileName $project.projectFile
    $p = $content.data.organization.projectV2

    # Project info
    $project.id = $p.id
    $project.owner = $p.owner.login
    $project.number = $p.number
    $project.url = $p.url

    # Add Items to mock
    Add-ItemsToMock -project $project

    #############################
    # Update Status on DueDate  #
    #############################
    <#
    $prj = Get-Project -Owner octodemo -ProjectNumber 625
    $prj.items.values | Select id,title,DueDate,Status,Comment | Sort-Object title | ft

    id                           Title                       DueDate    Status         Comment
    --                           -----                       -------    ------         -------
    PVTI_lADOAlIw4c4A0Lf4zgYNTyM draft0                      2025-03-01 Planned        Change AR Past
    PVTI_lADOAlIw4c4A0Lf4zgYVsJc draft1                      9999-12-12 Planned        Ignore as Future
    PVTI_lADOAlIw4c4A0Lf4zgfNuvM draft2                      9999-12-12 ActionRequired Change to P as AR+Future
    PVTI_lADOAlIw4c4A0Lf4zgfNum4 draft3                      2025-03-03 ActionRequired Ignore as Past and AR
    PVTI_lADOAlIw4c4A0Lf4zgYNTxI draft4                      2025-03-09 In Progress    (ignore not P)  | (Changed AR as Past)
    PVTI_lADOAlIw4c4A0Lf4zgfN77A draft5                      2025-03-15 Todo            (ignore not P)  | (Change AR as Today)
    PVTI_lADOAlIw4c4A0Lf4zgfN-44 draft6                      2025-03-15 Planned        Change to AR as P and Today
    PVTI_lADOAlIw4c4A0Lf4zgYNTc0 draft7                      2025-03-05 Done           Ignore as Done | (Change AR as Past)
    PVTI_lADOAlIw4c4A0Lf4zgYNTwo draft8                      9999-12-12 In Progress    Ignore future
    PVTI_lADOAlIw4c4A0Lf4zgfOmpo draft9                      9999-12-12 Todo           (Ignore not P) 
    PVTI_lADOAlIw4c4A0Lf4zgfJYv4 Issue for development                                 skip no DueDate
    PVTI_lADOAlIw4c4A0Lf4zgfJYvk PullRequest for development                           skip no DueDate

    #>
    $statusFieldName = "Status"
    $dateFieldName = "DueDate"
    $statusAction = "ActionRequired"
    $statusPlanned = "Planned"
    
    $sf = ($content.data.organization.projectV2.fields.nodes | Where-Object { $_.name -eq $statusFieldName })
    $df = ($content.data.organization.projectV2.fields.nodes | Where-Object { $_.name -eq $dateFieldName })
    $project.updateStatusOnDueDate = @{
        statusAction                   = $statusAction
        statusPlanned                  = $statusPlanned
        statusDoneOther                = "Todo"
        fields                         = @{ status = $sf ; dueDate = $df }
        staged                         = @{
            "PVTI_lADOAlIw4c4A0Lf4zgYNTyM" = @{ $($sf.id) = $statusAction } # draft0
            "PVTI_lADOAlIw4c4A0Lf4zgfN-44" = @{ $($sf.id) = $statusAction } # draft5
            "PVTI_lADOAlIw4c4A0Lf4zgfNuvM" = @{ $($sf.id) = $statusPlanned } # draft2
        }
        anyStatus                      = @{
            "PVTI_lADOAlIw4c4A0Lf4zgYNTxI" = @{ $($sf.id) = $statusAction } # draft4
            "PVTI_lADOAlIw4c4A0Lf4zgfN77A" = @{ $($sf.id) = $statusAction } # draft9
            
        }
        includeDone                    = @{
            "PVTI_lADOAlIw4c4A0Lf4zgYNTc0" = @{ $($df.id) = "" } # draft8
            
        }
        includeDoneOther               = @{
            "PVTI_lADOAlIw4c4A0Lf4zgfN77A" = @{ $($df.id) = "" } # draft5
            "PVTI_lADOAlIw4c4A0Lf4zgfOmpo" = @{ $($df.id) = "" } # draft9
        }
        anyStatus_and_includeDoneOther = @{
            "PVTI_lADOAlIw4c4A0Lf4zgYNTxI" = @{ $($sf.id) = $statusAction } # draft4
            "PVTI_lADOAlIw4c4A0Lf4zgfN77A" = @{ $($df.id) = "" } # draft5
            "PVTI_lADOAlIw4c4A0Lf4zgfOmpo" = @{ $($df.id) = "" } # draft9
        }
    }

    #############################
    # Update With Integration   #
    #############################

    $project.updateWithIntegration = @{
        fieldSlug = "sf_"
        integrationField = "sfUrl"
        fields = @("sf_Int2","sf_Text1")
        
        integrationCommand = "Get-SfAccount"

        mockdata1 = @{
            command = 'Get-SfAccount "https://some.com/1234/viuew"'
            data = @{
                "Text1"   = "value11"
                "Text2"   = "value12"
                "Number1" = 11
                "Int2"    = 111
            }
        }

        mockdata2 = @{
            command = 'Get-SfAccount "https://some.com/4321/viuew"'
            data = @{
                "Text1"   = "value21"
                "Text2"   = "value22"
                "Number1" = 22
                "Int2"    = 222
            }
        }

        staged =@{
            PVTI_lADOAlIw4c4A0Lf4zgfJYv4 = @{
                PVTF_lADOAlIw4c4A0Lf4zg15NKg = 222
                PVTF_lADOAlIw4c4A0Lf4zg15NMg = "value21"
            }
            PVTI_lADOAlIw4c4A0Lf4zgfJYvk = @{
                PVTF_lADOAlIw4c4A0Lf4zg15NKg = 111
                PVTF_lADOAlIw4c4A0Lf4zg15NMg = "value11"
            }

        } 
    }


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