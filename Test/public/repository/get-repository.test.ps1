function Test_GetRepository{

    Reset-InvokeCommandMock
    Mock_DatabaseRoot
    
    $p = Get-Mock_Project_700 ;
    $r = $p.repository
    
    MockCallJson -Command "Invoke-Repository -Owner $($r.owner) -Name $($r.name)" -FileName "invoke-repository-$($r.name).json"

    $result = Get-Repository -Owner $r.owner -Name $r.name

    #Assert
    foreach ( $key in $r.Keys ){
        Assert-AreEqual -Expected:$r.$key -Presented:$result.$key
    }
}