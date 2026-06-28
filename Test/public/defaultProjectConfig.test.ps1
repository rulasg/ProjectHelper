function Test_ProjectConfig_Default{

    # Get Enum list
    $enumList =Invoke-privateContext {
        $enumbcount = [ConfigKey]::GetNames([ConfigKey])
        return $enumbcount
    }
    
    # Get default values using public fuction
    $default = Get-ProjectConfigDefaults
    
    # Check the same number of items
    Assert-AreEqual -Expected $default.Count -Presented $enumList.count

    # Check deafault has values for all the key list items
    foreach ($key in $enumList){
        Assert-IsNotNull -Object $default.$key
    }
}