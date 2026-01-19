function Test_FindProject_SUCCESS {

    Reset-InvokeCommandMock

    $owner = "github"

    # Empty list
    $pattern = "emptylistpattern"
    $mockfilename = "findprojectempty.json"
    $command = 'Invoke-FindProject -Owner {owner} -Pattern "{pattern}" -firstProject 100 -afterProject ""'
    $command = $command -replace "{owner}", $owner
    $command = $command -replace "{pattern}", $pattern
     MockCallJson -Command $command -filename $mockfilename

    # With list
    $pattern = "kk"
    $mockfilename = "findprojectwithlist.json"
    $command = 'Invoke-FindProject -Owner {owner} -Pattern "{pattern}" -firstProject 100 -afterProject ""'
    $command = $command -replace "{owner}", $owner
    $command = $command -replace "{pattern}", $pattern
    MockCallJson -Command $command -filename $mockfilename

    # Act
    $result = Find-Project -Owner $owner -Pattern $pattern

    Assert-Count -Expected 3 -Presented $result

    Assert-AreEqual -Expected $result[1].id        -Presented  "PVT_kwDNJr_OANANzQ"
    Assert-AreEqual -Expected $result[1].title     -Presented  "title for project 21323"
    Assert-AreEqual -Expected $result[1].number    -Presented  "21323"
    Assert-AreEqual -Expected $result[1].url       -Presented  "https://github.com/orgs/testorg/projects/21323"
    Assert-AreEqual -Expected $result[1].createdAt -Presented  "3/10/2025 1:43:16 PM"
    Assert-AreEqual -Expected $result[1].updatedAt -Presented  "3/21/2025 12:59:34 PM"
    Assert-IsNull -Object $result[1].closedAt
}