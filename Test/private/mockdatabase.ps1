function Mock_DatabaseRoot([switch]$NotReset){

    MockCallToString "Invoke-ProjectHelperGetDatabaseStorePath" -OutString "test_database_path"

    #check $NotReset
    if(-Not $NotReset){
        Reset-DatabaseStore
    }
}

