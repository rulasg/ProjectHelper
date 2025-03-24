function Test_UpdateProjectItemsWithIntegration{

    Assert-SkipTest

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $owner = "github"
    $projectNumber = "20521"

    $params = @{
        Owner = $owner
        ProjectNumber = $projectNumber
        IntegrationField = "SfUrl"
        IntegrationCommand = "Get-SfAccount"
        Slug = "sf_"
    }

    Update-ProjectItemsWithIntegration @params

    Show-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-NotImplemented
}
