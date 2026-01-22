function Invoke-CreateIssue {
    param(
        [Parameter(Mandatory=$true)][string]$RepositoryId,      # Node ID of the repository
        [Parameter(Mandatory=$true)][string]$Title,             # Title for the issue
        [Parameter()][string]$Body                             # Issue body/description

        #[Parameter()][string[]]$ProjectIds                      # Node IDs of projects
        # [Parameter()][string]$ParentIssueId,                    # Node ID of parent issue
        # [Parameter()][string]$ClientMutationId,                 # Client mutation identifier
        # [Parameter()][string[]]$AssigneeIds,                    # Node IDs of assignees
        # [Parameter()][string[]]$LabelIds,                       # Node IDs of labels
        # [Parameter()][string]$IssueTemplate,                    # Issue template name
        # [Parameter()][string]$IssueTypeId,                      # Node ID of issue type
        # [Parameter()][string]$MilestoneId                      # Node ID of milestone
    )

    $query = Get-GraphQLString "createIssue.mutant"

    $variables = @{
        input = @{
            repositoryId    = $RepositoryId
            title           = $Title | ConvertTo-InvokeParameterString
            body            = $Body | ConvertTo-InvokeParameterString

            #projectIds      = $ProjectIds
            # assigneeIds     = $AssigneeIds
            # clientMutationId= $ClientMutationId
            # issueTemplate   = $IssueTemplate
            # issueTypeId     = $IssueTypeId
            # labelIds        = $LabelIds
            # milestoneId     = $MilestoneId
            # parentIssueId   = $ParentIssueId
        }
    }

    $response = Invoke-GraphQL -Query $query -Variables $variables

    return $response
} Export-ModuleMember -Function Invoke-CreateIssue