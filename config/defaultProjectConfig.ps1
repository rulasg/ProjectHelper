# Default values for th econfiguration of any project for Stub integration

enum ConfigKey {
    module
    stubcommand
    FieldName_DueDate
    FieldName_Comment
    Status_Ready
    Status_Closed
    Status_Backlog
}

$script:DEFAULT_CONFIG_VALUES = @{
    module            = "ProjectHelper"
    stubcommand       = "Invoke-StubCall"
    FieldName_DueDate = "DueDate"
    FieldName_Comment = "Comment"
    Status_Ready      = "In Progress"
    Status_Closed     = "Done"
    Status_Backlog    = "Todo"
}