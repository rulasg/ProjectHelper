
function Set-Commands{

    $global:GhCommands = @{
        Issue_Create           = 'gh issue create --repo "{0}" --title "{1}" --body "{2}"'
        Issue_List             = 'gh issue list --repo {0} --json number,title,state,url'
        Project_Field_List     = 'gh project field-list {0} --owner {1}'
        Project_Item_List      = 'gh project item-list {0} --owner "{1}"'
        Project_Item_Add       = 'gh project item-add {0} --owner {1} --url {2}'
        Project_Item_Delete    = 'gh project item-delete {0} --owner $owner --id {1}'
        Project_Item_Edit_Text = 'gh project item-edit --project-id {0} --id {1} --field-id {2} --text {3}'
        Project_Item_Create    = 'gh project item-create {0} --owner "{1}" --title "{2}" --body "{3}"'
        Project_List           = 'gh project list --owner "{0}" --limit 1000 --format json'
        Repo_List              = 'gh repo list {0} --limit 1000  --no-archived --source --json {1}"'
        Repo_Edit_Add_Topic    = 'gh repo edit {0} --add-topic {1}'
    }
}

Set-Commands