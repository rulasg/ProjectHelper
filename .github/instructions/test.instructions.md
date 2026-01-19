---
applyTo: '**/*.test.ps1'
---

# Test File Creation Guidelines

## Test File Location and Naming

### File Placement
Test files must mirror the exact folder structure of the source code:

- **Source**: `public/code.ps1` → **Test**: `Test/public/code.test.ps1`
- **Source**: `public/driver/invoke-getnode.ps1` → **Test**: `Test/public/driver/invoke-getnode.test.ps1`
- **Source**: `public/issues/Get-ProjectIssue.ps1` → **Test**: `Test/public/issues/Get-ProjectIssue.test.ps1`
- **Source**: `private/dates.ps1` → **Test**: `Test/private/dates.test.ps1`

The folder structure in `Test/` must exactly match the structure in the main module.

### Test Function Naming
- **Format**: `Test_<FunctionName>_<Scenario>`
- **PascalCase**: Match the actual function name (e.g., `Add-ProjectUser` → `Test_AddProjectUser_*`)
- **Scenario Suffix**: Use descriptive words indicating the test goal:
  - `SUCCESS` - Happy path / successful execution
  - `SUCCESS_SingleUser` - Variant of success with specific condition
  - `SUCCESS_MultipleUser` - Another variant with different parameters
  - `NotFound` - Resource not found error case
  - `InvalidInput` - Invalid parameter error case
  - `ERROR` - General error condition

**Examples**:
```powershell
function Test_FindProject_SUCCESS { }
function Test_AddProjectUser_SUCCESS_SingleUser { }
function Test_AddProjectUser_SUCCESS_MultipleUser { }
function Test_GetProjectIssue_NotFound { }
```

## Test Structure - AAA Pattern

All test functions must follow the **Arrange-Act-Assert** pattern with explicit comments:

### 1. ARRANGE Phase
```powershell
# Arrange
Reset-InvokeCommandMock  # CRITICAL: Always reset mocks at the start
Mock_DatabaseRoot        # Setup test database if needed

$owner = "github"
$projectNumber = 123
```

**Critical Setup Steps**:
- **ALWAYS** call `Reset-InvokeCommandMock` at the very beginning of the Arrange phase
- Setup any mock data using `Mock_*` helpers (e.g., `Mock_DatabaseRoot`, `Get-Mock_Project_700`)
- Define test input parameters and expected values
- Setup mock calls using `MockCallJson` or `MockCall_*` helpers

### 2. ACT Phase
```powershell
# Act
$result = Add-ProjectUser -Owner $owner -ProjectNumber $projectNumber -Handle "testuser" -Role "WRITER"
```

**Important**:
- Execute the function being tested
- Use the parameters and mocks prepared in Arrange phase
- Capture the result for assertions

### 3. ASSERT Phase
```powershell
# Assert
Assert-IsTrue $result
Assert-AreEqual -Expected "expected-value" -Presented $result.id
Assert-Count -Expected 3 -Presented $result
```

**Available Assertions**:
- `Assert-IsTrue` - Verify condition is true
- `Assert-IsNull` - Verify value is null
- `Assert-AreEqual` - Compare expected vs actual value
- `Assert-Contains` - Check if value is in collection
- `Assert-Count` - Verify collection count
- `Assert-NotImplemented` - For stub/empty test implementations

## Mocking Invoke-MyCommand Dependencies

When your test function calls a function that uses `Invoke-MyCommand`, you must mock those dependencies.

### Why Mocking is Critical
The module uses `Invoke-MyCommand` for dynamic command dispatch to enable testing without actual API calls. Any function calling `Invoke-MyCommand` indirectly must have those calls mocked.

### Mock Setup Pattern
```powershell
# Arrange
Reset-InvokeCommandMock

# Mock the Invoke-* driver function calls
MockCallJson -Command "Invoke-GetUser -Handle testuser" -File "invoke-GetUser-testuser.json"
MockCallJson -Command "Invoke-UpdateProjectV2Collaborators -ProjectId PVT_123 -collaborators ""ID123"" -Role ""WRITER""" -File "invoke-UpdateProjectV2Collaborators-ID123.json"

# Act
$result = Add-ProjectUser -Owner "github" -ProjectNumber 123 -Handle "testuser" -Role "WRITER"
```

### Mock Files
Mock response files should be stored in `Test/private/mocks/` and contain realistic GitHub API responses as JSON.

### Common Mock Helpers
- `Reset-InvokeCommandMock` - Clear all mocks (MUST be called first)
- `MockCallJson -Command "..." -File "..."` - Mock a driver function call with JSON response
- `MockCall_GetProject $project -SkipItems` - Pre-configured mock for Get-Project
- `Mock_DatabaseRoot` - Setup database root for project operations
- `Get-Mock_Project_700` - Get pre-configured test project
- `Get-Mock_Users` - Get pre-configured test users

## Empty/Stub Test Implementation

When creating a test function as a placeholder to be implemented later:

```powershell
function Test_SomeFunction_NotYetImplemented {
    Assert-NotImplemented
}
```

This allows the test infrastructure to recognize the test while explicitly marking it as not ready.

## Real Test Examples

### Example 1: Simple Success Case
```powershell
function Test_FindProject_SUCCESS {

    # Arrange
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $owner = "github"
    $pattern = "kk"
    $command = 'Invoke-FindProject -Owner {owner} -Pattern "{pattern}" -firstProject 100 -afterProject ""'
    $command = $command -replace "{owner}", $owner
    $command = $command -replace "{pattern}", $pattern
    MockCallJson -Command $command -filename "findprojectwithlist.json"

    # Act
    $result = Find-Project -Owner $owner -Pattern $pattern

    # Assert
    Assert-Count -Expected 3 -Presented $result
    Assert-AreEqual -Expected "PVT_kwDNJr_OANANzQ" -Presented $result[1].id
}
```

### Example 2: Single vs Multiple User Variants
```powershell
function Test_AddProjectUser_SUCCESS_SingleUser {

    # Arrange
    $p = Get-Mock_Project_700
    $owner = $p.Owner
    $projectNumber = $p.Number
    $projectId = $p.id
    MockCall_GetProject $p -SkipItems

    $u = Get-Mock_Users
    $userId = $u.u1.id
    $userName = $u.u1.name
    $role = "WRITER"

    MockCallJson -Command "Invoke-GetUser -Handle $userName" -File $u.u1.file
    MockCallJson -Command "Invoke-UpdateProjectV2Collaborators -ProjectId $projectId -collaborators ""$userId"" -Role ""$role""" -File "invoke-UpdateProjectV2Collaborators-$userId.json"

    # Act
    $result = Add-ProjectUser -Owner $owner -ProjectNumber $projectNumber -Handle $userName -Role $role

    # Assert
    Assert-IsTrue $result
}

function Test_AddProjectUser_SUCCESS_MultipleUser {

    # Arrange
    $p = Get-Mock_Project_700 ; $owner = $p.Owner ; $projectNumber = $p.Number ; $projectId = $p.id
    MockCall_GetProject $p -SkipItems

    $u = Get-Mock_Users
    $userId1 = $u.u1.id
    $userName1 = $u.u1.name
    $userId2 = $u.u2.id
    $userName2 = $u.u2.name
    $userNames = "$userName1", "$userName2"
    $usersIds = "$userId1 $userId2"
    $role = "WRITER"

    MockCallJson -Command "Invoke-GetUser -Handle $userName1" -File $u.u1.file
    MockCallJson -Command "Invoke-GetUser -Handle $userName2" -File $u.u2.file
    MockCallJson -Command "Invoke-UpdateProjectV2Collaborators -ProjectId $projectId -collaborators ""$usersIds"" -Role ""$role""" -File "invoke-UpdateProjectV2Collaborators-$userId1-$userId2.json"

    # Act
    $result = $userNames | Add-ProjectUser -Owner $owner -ProjectNumber $projectNumber -Role $role

    # Assert
    Assert-IsTrue $result
}
```

## Checklist Before Submitting Test

- [ ] Test file is in correct location: `Test/<source-path>/<filename>.test.ps1`
- [ ] Test function named: `Test_<FunctionName>_<Scenario>`
- [ ] Three phases clearly marked with comments: `# Arrange`, `# Act`, `# Assert`
- [ ] `Reset-InvokeCommandMock` called at start of Arrange phase
- [ ] All `Invoke-MyCommand` calls mocked with `MockCallJson`
- [ ] Assertions verify expected behavior
- [ ] Empty test uses `Assert-NotImplemented`
- [ ] No actual API calls made (all mocked)
