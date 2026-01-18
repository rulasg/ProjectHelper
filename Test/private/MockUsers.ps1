function Get-Mock_Users{
    $users = @{
        u1 = @{
            id = "MDQ6VXNlcjY4ODQ0MDg="
            name = "rulasg"
            file = "invoke-GetUser-rulasg.json"
        }
        u2 = @{
            id = "U_kgDOC_E3gw"
            name = "rauldibildos"
            file = "invoke-GetUser-rauldibildos.json"
        }
    }

    return $users
}