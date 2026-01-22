

function Test_UpdateProjectWithInjection{

    # https://github.com/orgs/octodemo/projects/625/views/1

    $mp = Get-Mock_Project_625 ; $owner = $mp.owner ; $projectNumber = $mp.number
    MockCall_GetProject -MockProject $mp
    $p = $mp.updateWithInjection

    # Define global integration functions
    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        $params = @{
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            ItemId = $p.item1.id
            FieldName = $p.field1.name
            Value = "Value updated from integration1"
        }
        Edit-ProjectItem @params
    }

    # Expected staged info for invoke-ProjectInjection_1
    $expectedStaged = @{
        $($p.item1.id) = @{
            $($p.field1.id) = "Value updated from integration1"
        }
    }

    function global:Invoke-ProjectInjection_2 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )
        "String from integration1" | Write-Host

        $params = @{
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            ItemId = $p.item2.id
            FieldName = $p.field2.name
            Value = "Value updated from integration2"
            }
            Edit-ProjectItem @params
    }

    # Expected staged info for invoke-ProjectInjection_2
    $expectedStaged += @{
        $($p.item2.id) = @{
            $($p.field2.id) = "Value updated from integration2"
        }
    }

    MockCallToObject -Command 'Invoke-ProjectInjectionFunctions' -OutObject @("Invoke-ProjectInjection_1","Invoke-ProjectInjection_2")

    # Act
   $result = Update-ProjectItemsWithInjection -owner $Owner -ProjectNumber $ProjectNumber

   Assert-AreEqual -Expected 2 -Presented $result.Pass
   Assert-AreEqual -Expected 2 -Presented $result.Integrations
   Assert-Contains -Expected "Invoke-ProjectInjection_1" -Presented $result.IntegrationsName
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.IntegrationsName

    # Confirm that the changes are staged
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    # Items edited
    Assert-AreEqual -Expected $expectedStaged.Count -Presented $staged.Count -Comment "Items staged"
    foreach($id in $expectedStaged.Keys){
        foreach($field in $expectedStaged.$id.Keys){
            Assert-AreEqual -Expected $expectedStaged.$id.$field -Presented $staged.$id.$field.Value -Comment "Item $id Field $field"
        }
    }
}

function Test_UpdateProjectWithInjection_Failed_1{

    # https://github.com/orgs/octodemo/projects/625/views/1

    $mp = Get-Mock_Project_625 ; $owner = $mp.owner ; $projectNumber = $mp.number
    MockCall_GetProject -MockProject $mp
    $p = $mp.updateWithInjection

    # Define global integration functions
    function global:Invoke-ProjectInjection_1 {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber
    )

        "String from integration1" | Write-Host

        $params = @{
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            ItemId = $p.item1.id
            FieldName = $p.field1.name
            Value = "Value updated from integration1"
        }
        Edit-ProjectItem @params
    }

    # Expected staged info for invoke-ProjectInjection_1
    $expectedStaged = @{
        $($p.item1.id) = @{
            $($p.field1.id) = "Value updated from integration1"
        }
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

     MockCallToObject -Command 'Invoke-ProjectInjectionFunctions' -OutObject @("Invoke-ProjectInjection_1","Invoke-ProjectInjection_2")

    # Act
   $result = Update-ProjectItemsWithInjection -Owner $Owner -ProjectNumber $ProjectNumber

   Assert-AreEqual -Expected 2                           -Presented $result.Integrations
   Assert-Contains -Expected "Invoke-ProjectInjection_1" -Presented $result.IntegrationsName
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.IntegrationsName

   Assert-AreEqual -Expected 1                           -Presented $result.Pass

   Assert-AreEqual -Expected 1                           -Presented $result.Failed
   Assert-Contains -Expected "Invoke-ProjectInjection_2" -Presented $result.FailedIntegration
   Assert-AreEqual -Expected "Integration 2 failed" -Presented $result.FailedIntegrationErrors."Invoke-ProjectInjection_2".Exception.Message
   Assert-AreEqual -Expected "Integration 2 failed" -Presented $global:FailedIntegrationErrors."Invoke-ProjectInjection_2".Exception.Message

    # Confirm that the changes are staged
    $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    # Items edited
    Assert-AreEqual -Expected $expectedStaged.Count -Presented $staged.Count -Comment "Items staged"
    foreach($id in $expectedStaged.Keys){
        foreach($field in $expectedStaged.$id.Keys){
            Assert-AreEqual -Expected $expectedStaged.$id.$field -Presented $staged.$id.$field.Value -Comment "Item $id Field $field"
        }
    }

}

function Test_InvokeProjectInjection{

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
