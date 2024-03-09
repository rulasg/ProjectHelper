
function ProjectHelperTest_CommitProjectItemsStaged_NoStaged{
    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "Solidifydemo" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    Start-MyTranscript
    $result = Save-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    $t = Stop-MyTranscript

    Assert-Contains -Presented $t -Expected "Nothing to commit"
    Assert-IsNull -Object $result
}

function ProjectHelperTest_CommitProjectItemsStaged_SUCCESS{
    Reset-InvokeCommandMock
    Initialize-DatabaseRoot

    $Owner = "Solidifydemo" ; $ProjectNumber = 164 ; $itemsCount = 12 ; $fieldsCount = 18
    Set-InvokeCommandMock -Alias GitHubOrgProjectWithFields -Command "MockCall_GitHubOrgProjectWithFields -Owner $Owner -Project $projectNumber"

    # Item id 10
    # Name                           Value
    # ----                           -----
    # id                             PVTI_lADOBCrGTM4ActQazgMuXXc
    # number                         
    # Severity                       Nice⭐️
    # Status                         Todo
    # TimeTracker                    890
    # Comment                        This
    # body                           some content in body
    # Assignees                      rulasg
    # UserStories                    8
    # Title                          A draft in the project
    # Priority                       🥵High
    # url                            
    # type                           DraftIssue

    $itemId = "PVTI_lADOBCrGTM4ActQazgMuXXc"

    $fieldComment = "comment" ; $fieldCommentValue = "new value of the comment 10"
    $fieldTitle = "title" ; $fieldTitleValue = "new value of the title"

    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue

    # Name                           Value
    # ----                           -----
    # number                         6
    # id                             PVTI_lADOBCrGTM4ActQazgMueM4
    # body                           
    # type                           PullRequest
    # Start Date                     2024-02-23
    # Repository                     https://github.com/SolidifyDemo/ProjectDemoTest-repo-front
    # Title                          Update README.md
    # Assignees                      rulasg
    # TimeTracker                    888
    # Status                         In Progress
    # Next Action Date               2024-02-23
    # url                            https://github.com/SolidifyDemo/ProjectDemoTest-repo-front/pull/6
    # $result = Get-ProjectItemList -Owner $Owner -ProjectNumber $ProjectNumber


    $itemId = "PVTI_lADOBCrGTM4ActQazgMueM4"
    $fieldComment = "comment" ; $fileCommentValue = "new value of the comment 11"
    $fieldTitle = "title" ; $fileTitleValue = "new value of the title 11"

    Edit-ProjectItem $owner $projectNumber $itemId $fieldComment $fieldCommentValue
    Edit-ProjectItem $owner $projectNumber $itemId $fieldTitle $fieldTitleValue


    # Start-MyTranscript
    $result = Save-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
    # $tt = Stop-MyTranscript

    Assert-NotImplemented

}