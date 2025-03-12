function Mock_DatabaseRoot(){

    MockCallToString "Invoke-ProjectHelperGetDatabaseStorePath" -OutString "test_database_path"

    Reset-DatabaseStore
}