function Test_EditProjectItemWithValues_Integration{

    # Assert-SkipTest
    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"

    Mock_GetProject_Octodemop_625

    $data = @{
        "Text1" = "value1"
        "Text2" = "value2"
        "Text3" = "value3"
        "Number1" = "value3"
    }

    $result = Edit-ProjectItemWithValues -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId -Values $data -FieldSlug $FieldSlug

    # Assert - Confirm update
    # Assert-IsNull -Object $result

    $result = Get-ProjectItem -Owner $owner -ProjectNumber $projectNumber -ItemId $itemId

    Assert-AreEqual -expected $data.Text1 -Presented $result.$($FieldSlug + "Text1")
    Assert-AreEqual -expected $data.Text2 -Presented $result.$($FieldSlug + "Text2")
    # Assert-AreEqual -expected $data.Text3 -Presented $result.$($FieldSlug + "Text3") 
    Assert-AreEqual -expected $data.Number1 -Presented $result.$($FieldSlug + "Number1")

    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 3 -Presented $result.$itemId

}


function Test_UpdateProjectWithIntegration{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # https://github.com/orgs/octodemo/projects/625/views/1

    $owner = "octodemo"
    $projectNumber = "625"
    $itemId = "PVTI_lADOAlIw4c4A0Lf4zgYNTc0"
    $fieldSlug = "sf_"
    $IntegrationField = "sfUrl"
    $IntegrationCommand = "Get-SfAccount"

    Mock_GetProject_Octodemop_625

    $data1 = @{
        "Text1" = "value11"
        "Text2" = "value12"
        "Text3" = "value13"
        "Number1" = 11
    }

    $data2 = @{
        "Text1" = "value21"
        "Text2" = "value22"
        "Text3" = "value23"
        "Number1" = 22
    }

    MockCallToObject -Command "Get-SfAccount https://some.com/1234/viuew" -OutObject $data1
    MockCallToObject -Command "Get-SfAccount https://some.com/4321/viuew" -OutObject $data2

    $param = @{
        Owner = $owner
        ProjectNumber = $projectNumber
        IntegrationField = $IntegrationField
        IntegrationCommand = $IntegrationCommand
        Slug = $fieldSlug
    }

   $result = Update-ItemWithIntegration @param


    # Confirm that the changes are staged
    $result = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected 2 -Presented $result

    # PVTI_lADOAlIw4c4A0Lf4zgYNTc0
    Assert-AreEqual -Expected $($data1.Text1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value
    Assert-AreEqual -Expected $($data1.Text2) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value
    Assert-AreEqual -Expected $($data1.Number1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTc0.PVTF_lADOAlIw4c4A0Lf4zgp2mBs.Value
    
    # PVTI_lADOAlIw4c4A0Lf4zgYNTxI
    Assert-AreEqual -Expected $($data2.Text1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2lxM.Value
    Assert-AreEqual -Expected $($data2.Text2) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2l3o.Value
    Assert-AreEqual -Expected $($data2.Number1) -Presented $result.PVTI_lADOAlIw4c4A0Lf4zgYNTxI.PVTF_lADOAlIw4c4A0Lf4zgp2mBs.Value
}

<#
.SYNOPSIS
    Update all the items of a project with an integration command
.DESCRIPTION
    Update all the items of a project with an integration command
    The function will update all the items of a project with the values returned by the integration command
    The integration command will be called for each Item with the value of the integration field as parameter.
    The integration command must return a hashtable with the values to be updated
    The project fields to be updated will have the same name as the hash table keys with a slug as suffix
    If an item has a field with the name `sf_Name` it will be updated with the value of the hashtable key Name if the slug defined is "sf_"
.EXAMPLE
    Update-ItemWithIntegration -Owner "someOwner" -ProjectNumber 164 -IntegrationField "sfUrl" -IntegrationCommand "Get-SfAccount" -Slug "sf_"
#>
function Update-ItemWithIntegration{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber,
        [Parameter(Mandatory)][string]$IntegrationField,
        [Parameter(Mandatory)][string]$IntegrationCommand,
        [Parameter()] [string]$Slug
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project
    $project = Get-Project -Owner $owner -ProjectNumber $projectNumber

    # Extract all items that have value on the integration field.
    # This field is the value that will work as parameter to the integration command
    $itemList = $project.items.Values | Where-Object { -Not [string]::IsNullOrWhiteSpace($_.$IntegrationField) }

    foreach($item in $itemList){
        
        try {
            $values = Invoke-MyCommand -Command "$IntegrationCommand $($item.$IntegrationField)"
        }
        catch {
            "Something went wrong with the integration command for $($item.id)" | Write-Host -ForegroundColor Red
        }
        # Call the ingetration Command with the integration field value as parameter

        # Check if Values is empty or null
        if($null -eq $values -or $values.Count -eq 0){
            "No values returned from the integration commandfor $($item.id)" | Write-Host -ForegroundColor Yellow
            continue
        }

        # Edit item with the value
        $param = @{
            Owner = $owner
            ProjectNumber = $projectNumber
            ItemId = $item.id
            Values = $values
            FieldSlug = $Slug
        }

        Edit-ProjectItemWithValues @param
    }

    
} 

function Mock_GetProject_Octodemop_625{

    $owner = "octodemo"
    $projectNumber = "625"

    $params = @{

        Command = "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber"
        Filename = "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.2.json"
    }

    # MockCallJson -Command "Invoke-GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectnumber" -Filename "invoke-GitHubOrgProjectWithFields-$owner-$projectNumber.2.json"
    MockCallJson @params

}