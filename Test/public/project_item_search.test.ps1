# call Search-ProjectItem with no parameters will return all the items
function Test_SearchProjectItem_SUCCESS_NoParameters {

    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # Act
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -IncludeDone

    Assert-Count -Expected $p.items.totalCount -Presented $result
}

    

function Test_SearchProjectItem_SUCCESS_DefaultTitle{

    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number

    # title refrence with differnt case and spaces
    $title = $p.searchInTitle.titleFilter

    # Act
    $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter $title

    Assert-Count -Expected $p.searchInTitle.Titles.Count -Presented $result

    $p.searchInTitle.Titles | ForEach-Object {
        Assert-Contains -Expected $_ -Presented $result.Title
    }
}

function Test_SearchProjectItem_SUCCESS_FieldName_Like{

    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $p = $p.searchInFieldName.Like

    # Act
    $result = Search-ProjectItem -Filter $p.Filter -FieldName $p.FieldName  -IncludeDone -Owner $owner -ProjectNumber $projectNumber

    Assert-Count -Expected $p.Count -Presented $result
}

function Test_SearchProjectItem_SUCCESS_FieldName_Exact{



    MockCall_GetProject_700

    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $p = $p.searchInFieldName.Exact

    # Act
    $result = Search-ProjectItem -Filter $p.Filter -FieldName $p.FieldName -Exact  -IncludeDone -Owner $owner -ProjectNumber $projectNumber


    Assert-Count -Expected $p.Count -Presented $result
}


function Test_SearchProjectItem_SUCCESS_AnyField{

    MockCall_GetProject_700

    $p = Get-Mock_Project_700;  $owner = $p.owner ; $projectNumber = $p.number


    "development", "96", "rulasg-dev-1" | ForEach-Object{

        $result = Search-ProjectItem -Owner $owner -ProjectNumber $projectNumber -Filter $_ -IncludeDone -AnyField

        Assert-Count -Expected $p.searchInAnyField.$_.totalCount -Presented $result
        
        foreach ($r in $result) {
            Assert-Contains -Expected $r.Title -Presented $p.searchInAnyField.$_.Titles
        }
    }
}

function Test_SearchProjectItem_FAIL{

    $Owner = "SomeOrg" ; $ProjectNumber = 164
    $erroMessage= "Error: Project not found. Check owner and projectnumber"

    Mock_DatabaseRoot

    MockCall_GitHubOrgProjectWithFields_Null  -Owner $owner -ProjectNumber $projectNumber

    # Run the command
    Start-MyTranscript
    $result = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -filter "any"
    $tt = Stop-MyTranscript

    Assert-IsNull -Object $result
    Assert-Contains -Expected $erroMessage -Presented $tt
}