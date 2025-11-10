# Tests for Search-ProjectItem

function Test_SearchProjectItem_Basic_SUCCESS {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GetProject_700

    $p = Get-Mock_Project_700
    $Owner = $p.owner
    $ProjectNumber = $p.number
    $filter = $p.searchInTitle.titleFilter
    $expected = $p.searchInTitle.Titles.Count

    $result = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter $filter
    Assert-Count -Expected $expected -Presented $result

    # Default attributes should be id + Title
    foreach($r in $result){
        $props = $r.PSObject.Properties.Name
        Assert-Count -Expected 2 -Presented $props
        Assert-Contains -Expected "id" -Presented $props
        Assert-Contains -Expected "Title" -Presented $props
    }
}

function Test_SearchProjectItem_PassThru_SUCCESS {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GetProject_700

    $p = Get-Mock_Project_700
    $Owner = $p.owner
    $ProjectNumber = $p.number
    $filter = $p.searchInTitle.titleFilter
    $expected = $p.searchInTitle.Titles.Count

    $attributes = $p.searchInTitle.attributesDefault

    $raw = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter $filter -PassThru
    Assert-Count -Expected $expected -Presented $raw

    # Show (non PassThru) should produce PSCustomObject projection
    $shown = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter $filter -Attributes $attributes
    Assert-Count -Expected $expected -Presented $shown

    # Compare one item type difference
    Assert-IsTrue -Condition ($raw[0] -is [pscustomobject])
    Assert-IsTrue -Condition ($shown[0] -is [pscustomobject])
    Assert-Count -Expected $attributes.Count -Presented $($shown[0].PSObject.Properties.Name)

}

function Test_SearchProjectItem_SortByTitle_SUCCESS {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GetProject_700

    $p = Get-Mock_Project_700
    $Owner = $p.owner
    $ProjectNumber = $p.number
    $filter = $p.searchInTitle.titleFilter

    $result = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter $filter
    $titles = $result | ForEach-Object { $_.Title }
    $sorted = $titles | Sort-Object
    # Ensure already sorted (function sorts when Title in attributes)
    for($i=0;$i -lt $titles.Count;$i++){
        Assert-AreEqual -Expected $sorted[$i] -Presented $titles[$i] -Comment "Titles should be sorted alphabetically"
    }
}

function Test_SearchProjectItem_CustomAttributes_SUCCESS {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GetProject_700

    $p = Get-Mock_Project_700
    $Owner = $p.owner
    $ProjectNumber = $p.number
    $filter = $p.searchInTitle.titleFilter

    $attrs = $p.searchInTitle.attributes
    $result = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter $filter -Attributes $attrs
    foreach($r in $result){
        $props = $r.PSObject.Properties.Name
        Assert-Count -Expected $attrs.Count -Presented $props
        for($i=0;$i -lt $attrs.Count;$i++){
            Assert-AreEqual -Expected $attrs[$i] -Presented $props[$i] -Comment "Property order should match passed attributes"
        }
    }
}

function Test_SearchProjectItem_NoMatch {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    MockCall_GetProject_700

    $p = Get-Mock_Project_700
    $Owner = $p.owner
    $ProjectNumber = $p.number

    $result = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter "___DefinitelyNotInAnyTitle___"
    Assert-Count -Expected 0 -Presented $result
}

function Test_SearchProjectItem_AND_Filter_SUCCESS {
    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $p = Get-Mock_Project_700 ; $owner = $p.owner ; $projectNumber = $p.number
    $cacheFileName = $p.cacheFileName
    MockCall_GetProject $p -Cache
    $i = $p.issue

    $str = '"{title}"' -replace '{title}',$i.title
    $newStr = '"{title} UniqueSearchAlpha UniqueSearchBeta"' -replace '{title}',$i.title
    Update-Mock_DatabaseFileWithReplace -FileName $cacheFileName -SearchString $str -ReplaceString $newStr


    # Act
    $found = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter "UniqueSearchAlpha","UniqueSearchBeta"
    Assert-Count -Expected 1 -Presented $found
    Assert-AreEqual -Expected $i.id -Presented $found[0].id

    # Negative: second token missing
    $notFound = Search-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Filter "UniqueSearchAlpha","MissingZeta"
    Assert-Count -Expected 0 -Presented $notFound
}