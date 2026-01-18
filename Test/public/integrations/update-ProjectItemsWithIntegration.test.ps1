function Test_UpdateProjectWithIntegration{

    $mp = Get-Mock_Project_625 ; $owner = $mp.owner ; $projectNumber = $mp.number
    Mockcall_GetProject -MockProject $mp
    $p = $mp.updateWithIntegration

    # https://github.com/orgs/octodemo/projects/625/views/1

    $fieldSlug = $p.fieldSlug
    $integrationField = $p.integrationField
    $integrationCommand = $p.integrationCommand

    # Mock integration calles
    MockCallToObject -Command $p.mockdata1.command -OutObject $p.mockdata1.data
    MockCallToObject -Command $p.mockdata2.command -OutObject $p.mockdata2.data

    $param = @{
        Owner = $owner
        ProjectNumber = $projectNumber
        IntegrationField = $integrationField
        IntegrationCommand = $integrationCommand
        Slug = $fieldSlug
    }

    # Act
   $result = Update-ProjectItemsWithIntegration @param

   # Result is null
   Assert-IsNull -Object $result -Comment "Result is null"

    # Confirm that the changes are staged
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    # Items edited
    Assert-AreEqual -Expected $p.staged.Count -Presented $staged.Count -Comment "Items staged"
    foreach($id in $p.staged.Keys){
        foreach($field in $p.staged.$id.Keys){
            Assert-AreEqual -Expected $p.staged.$id.$field -Presented $staged.$id.$field.Value -Comment "Item $id Field $field"
        }
    }
}