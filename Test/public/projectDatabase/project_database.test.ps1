
function Test_SaveProjectDatabase_SafeId_Flag_PrivateCall{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    
    # Call on private mode
    $modulePath = $MODULE_PATH | Split-Path -Parent
    $module = Import-Module -Name $modulePath -PassThru

    & $module {
        $Owner = "SomeOrg" ; $ProjectNumber = 164
        # Cache the project
        $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber


        $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        Assert-IsNotNull -Object $prj.safeId
        
        # Update project and the safeId should be updated
        $oldSafeId = $prj.safeId
        Save-ProjectDatabaseSafe -Database $prj
        $prj2 = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        
        Assert-IsNotNull -Object $prj2.safeId
        Assert-AreNotEqual -Presented $oldSafeId -Expected $prj2.safeId
    }

}

function Test_SaveProjectDatabase_Safe_PrivateCall{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    MockCall_GitHubOrgProjectWithFields -Owner $owner -ProjectNumber $projectNumber -FileName 'projectV2.json'
    
    # Call on private mode
    $modulePath = $MODULE_PATH | Split-Path -Parent
    $module = Import-Module -Name $modulePath -PassThru

    & $module {

        $Owner = "SomeOrg" ; $ProjectNumber = 164
        # Cache the project
        $prj1 = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

        # modify the project
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber ; Save-ProjectDatabaseSafe -Database $db

        # Check that safeId has changed
        $prj2 = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber
        Assert-AreNotEqual -Presented $prj2.safeId -Expected $prj1.safeId
        
        ## When saving again as prj1 that has been saved before it will throw
        $hasThrow = $false
        try{
            Save-ProjectDatabaseSafe -Database $prj1
        } catch {
            $hasThrow = $true
        }
        Assert-IsTrue -Condition $hasThrow
    }

}