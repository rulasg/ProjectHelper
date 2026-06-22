function Test_GetUser_SUCCESS{

    MockCallJson -Command "Invoke-GetUser -Handle mona" -filename "invoke-GetUser-rulasg.json"

    # act
    $result = Get-User -Handle "mona"

    # Assert
    Assert-AreEqual -Expected "Mona Octocat" -Presented $result.Name
    Assert-AreEqual -Expected "mona" -Presented $result.Login
    Assert-AreEqual -Expected "MDQ6VXNlcjY4ODQ0MDg=" -Presented $result.Id
    Assert-AreEqual -Expected "mona@github.com" -Presented $result.Email
}