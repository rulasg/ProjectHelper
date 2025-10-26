function Test_GetRepository{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $p = Get-Mock_Project_700 ;
    $r = $p.repo
    $ro = $p.repo.object

    
    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName $p.repoFile

    $result = Get-Repository -Owner $r.owner -Name $r.name

    #Assert
    foreach ( $key in $ro.Keys ){
        Assert-AreEqual -Expected:$ro.$key -Presented:$result.$key
    }

    # Assert repo cache created
    $dbpath = get-Mock_DatabaseRootPath
    $dbname = "$($r.owner)-$($r.name).json"
    
    Assert-ItemExist -Path (Join-Path -Path $dbpath -ChildPath $dbname)

    # reset mocks and get repo to use cache
    Reset-InvokeCommandMock
    Mock_DatabaseRoot -NotReset

    $result = Get-Repository -Owner $r.owner -Name $r.name

    #Assert
    Assert-AreEqual -Expected:$r.id -Presented:$result.id
}