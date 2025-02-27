function Initialize-DatabaseRoot(){

    MockCallToString "Invoke-GetDatabaseStorePath" -OutString "test_database_path"

    Reset-DatabaseRoot
}