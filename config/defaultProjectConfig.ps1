# Default values for th econfiguration of any project for Stub integration

enum ConfigKey {
    stubcommand
    module
    DueDateFieldName
    CommentFieldName
    ReadyStatus
    ClosedStatus
    BacklogStatus
}

$DEFAULT_CONFIG_VALUES = @{
    stubcommand      = "Invoke-StubCall"
    module           = "ProjectHelper"
    DueDateFieldName = "DueDate"
    CommentFieldName = "Comment"
    ReadyStatus      = "In Progress"
    ClosedStatus     = "Done"
    BacklogStatus    = "Todo"
}