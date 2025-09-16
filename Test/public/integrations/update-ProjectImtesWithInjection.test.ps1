

function Test_UpdateProjectWithInjection{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # https://github.com/orgs/octodemo/projects/625/views/1

    $owner = "octodemo"
    $projectNumber = "625"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.json"

    New-ModuleV3 -Name IntegrationFunctions

    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        $params = @{
            ItemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTxI"
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            FieldName = "sf_Text1"
            Value = "Value updated from integration1"
        }
        Edit-ProjectItem @params

    }
    function global:Invoke-ProjectInjection_2 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )
        "String from integration1" | Write-Host

        $params = @{
            ItemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            FieldName = "sf_Text2"
            Value = "Value updated from integration2"
            }
            Edit-ProjectItem @params
    }

    $param = @{
        Owner = $Owner
        ProjectNumber = $ProjectNumber
    }

   $result = Update-ProjectItemsWithInjection @param

   Assert-AreEqual -Expected 2 -Presented $result.Pass
   Assert-AreEqual -Expected 2 -Presented $result.Integrations
   Assert-Contains -Expected "Invoke-ProjectInjection_1" -Presented $result.IntegrationsName
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.IntegrationsName

    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 2 -Presented $result

    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI
    Assert-AreEqual -Expected "Value updated from integration1" -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value

    # PVTI_lADOAlIw4c4A0Lf4zgYNTc0
    Assert-AreEqual -Expected "Value updated from integration2" -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value

}

function Test_UpdateProjectWithInjection_Failed_1{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # https://github.com/orgs/octodemo/projects/625/views/1

    $owner = "octodemo"
    $projectNumber = "625"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.json"

    New-ModuleV3 -Name IntegrationFunctions

    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        $params = @{
            ItemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTxI"
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            FieldName = "sf_Text1"
            Value = "Value updated from integration1"
        }
        Edit-ProjectItem @params

    }
    function global:Invoke-ProjectInjection_2 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )
        "String from integration1" | Write-Host

        throw "Integration 2 failed"
    }

    $param = @{
        Owner = $Owner
        ProjectNumber = $ProjectNumber
    }

   $result = Update-ProjectItemsWithInjection @param

   Assert-AreEqual -Expected 2                           -Presented $result.Integrations
   Assert-Contains -Expected "Invoke-ProjectInjection_1" -Presented $result.IntegrationsName
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.IntegrationsName

   Assert-AreEqual -Expected 1                           -Presented $result.Pass

   Assert-AreEqual -Expected 1                           -Presented $result.Failed
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.FailedIntegration
   Assert-AreEqual -Expected "Integration 2 failed" -Presented $result.FailedIntegrationErrors."Invoke-ProjectInjection_2".Exception.Message
   Assert-AreEqual -Expected "Integration 2 failed" -Presented $global:FailedIntegrationErrors."Invoke-ProjectInjection_2".Exception.Message


    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result

    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI
    Assert-AreEqual -Expected "Value updated from integration1" -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value

    # # PVTI_lADOAlIw4c4A0Lf4zgYNTc0
    # Assert-AreEqual -Expected "Value updated from integration2" -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value
}

function Test_InvokeProjectInjection{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $projectNumber = "625"

    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTxI"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber-skipitems.json" -skipitems

    MockCallJson -Command "Invoke-GetItem -itemid $itemId" -FileName "invoke-getitem-$itemId.json"

    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        $params = @{
            ItemId = $itemId
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            FieldName = "sf_Text1"
            Value = "Value updated from integration1"
        }
        Edit-ProjectItem @params

    }

    $result = Invoke-ProjectInjection -FunctionName "Invoke-ProjectInjection_1" -Owner $owner -ProjectNumber $projectNumber

    Assert-AreEqual -Expected 1 -Presented $result.Pass

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 1 -Presented $result
    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI
    Assert-AreEqual -Expected "Value updated from integration1" -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value
}

function Test_InvokeProjectInjection_Fail{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

        $owner = "octodemo"
    $projectNumber = "625"

    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber-skipitems.json" -SkipItems

    New-ModuleV3 -Name IntegrationFunctions

    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        throw "Integration 1 failed"

    }

    $result = Invoke-ProjectInjection -FunctionName "Invoke-ProjectInjection_1" -Owner $owner -ProjectNumber $projectNumber

   Assert-AreEqual -Expected 1                           -Presented $result.Failed
   Assert-Contains -Expected "Invoke-ProjectInjection_1" -Presented $result.FailedIntegration
   Assert-AreEqual -Expected "Integration 1 failed" -Presented $result.FailedIntegrationErrors."Invoke-ProjectInjection_1".Exception.Message
   Assert-AreEqual -Expected "Integration 1 failed" -Presented $global:FailedIntegrationErrors."Invoke-ProjectInjection_1".Exception.Message

    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 0 -Presented $result
}
