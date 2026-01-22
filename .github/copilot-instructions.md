# ProjectHelper Copilot Instructions

## Project Overview
**ProjectHelper** is a PowerShell module for GitHub Projects interaction via GraphQL API. It provides CLI-like functions to manage GitHub projects, items, users, and collaborators from PowerShell.

## Architecture & Core Patterns

### Module Structure
- **Loading Order** (`ProjectHelper.psm1`): `config` → `helper` → `include` → `private` → `public`
- **Public Functions**: Exported via `Export-ModuleMember -Function <name>` in each file
- **Private Functions**: In `/private` folder, not exported; used internally by public functions
- **Include Files** (`/include`): Shared utilities loaded early; example: `callAPI.ps1` (GraphQL/REST), `MyWrite.ps1` (logging)
- **Driver Functions** (`/public/driver`): Low-level integration with GitHub APIs; marked with comment "integration function not intended for direct user use"

### Key Files & Responsibilities
- `include/callAPI.ps1`: Handles `Invoke-GraphQL` and `Invoke-RestAPI` calls to GitHub
- `helper/invokeCommand.helper.ps1`: Provides `Invoke-MyCommand` for alias-based command dispatch (enables test mocking)
- `include/config.ps1`: Configuration storage in `~/.helpers/ProjectHelper/config/`
- `public/graphql/*.{query,mutant,tag}`: GraphQL template files (fragments and queries)
- `Test/Test.psd1`: Parallel test module with identical structure to main module

### Invocation Pattern (Critical for Testing)
```powershell
# Production: Direct API calls
Invoke-GraphQL -Query $query -Variables $variables

# High-level: Uses Invoke-MyCommand alias dispatch (mockable)
Invoke-MyCommand -Command "findProject" -Parameters @{owner=$Owner; pattern=$Pattern}

# Set custom implementation for testing/mocking:
Set-MyInvokeCommandAlias -Alias $alias -Command $Command
```

## Development Workflows

### Running Tests
```powershell
./test.ps1                          # Run all tests
./test.ps1 -ShowTestErrors          # Show error details
./test.ps1 -TestName "Test_*"       # Run specific test
```

Uses **TestingHelper** module from PSGallery (installed automatically).

### Building & Deploying
```powershell
./build.ps1                         # Build module
./deploy.ps1 -VersionTag "v1.0.0"  # Deploy to PSGallery
./sync.ps1                          # Sync with TestingHelper templates
```

### Debugging
Enable module debug output:
```powershell
Enable-ProjectHelperDebug
Disable-ProjectHelperDebug
```

## Code Patterns & Conventions

### GraphQL Integration
1. Store GraphQL in template files: `/public/graphql/queryName.query` or `.mutant`
2. Retrieve via: `Get-GraphQLString "queryName.query"`
3. Execute: `Invoke-GraphQL -Query $query -Variables $variables`

Example:
```powershell
$query = Get-GraphQLString "findProject.query"
$variables = @{ login = $Owner; pattern = $Pattern }
$response = Invoke-GraphQL -Query $query -Variables $variables
```

### Public vs. Private Functions
- **Public** (`/public`): User-facing, high-level; transform data, handle caching
- **Private** (`/private`): Lower-level helpers; return raw GitHub data
- **Driver** (`/public/driver`): Thin wrappers around API calls; minimal logic

### Command Aliases with Parameter Templates
Use `Set-MyInvokeCommandAlias` for dynamic command dispatch:
```powershell
Set-MyInvokeCommandAlias -Alias "findProject" -Command "Invoke-FindProject -Owner {owner} -Pattern {pattern}"
Invoke-MyCommand -Command "findProject" -Parameters @{owner="foo"; pattern="bar"}
```
This enables mocking in tests without changing implementation.

### Pipeline & Object Transformation
Functions support pipeline input for bulk operations:
```powershell
"user1", "user2" | Add-ProjectUser -Owner $owner -ProjectNumber 123 -Role "WRITER"
```

### Error Handling
- GraphQL errors: Check `$response.errors` before processing
- Include meaningful context in error messages
- Use `Write-MyError`, `Write-MyVerbose`, `Write-MyDebug` for consistent logging

## Testing Patterns

### Test File Location
Test files must mirror the module structure:
- **Source**: `public/code.ps1` → **Test**: `Test/public/code.test.ps1`
- **Source**: `public/driver/invoke-getnode.ps1` → **Test**: `Test/public/driver/invoke-getnode.test.ps1`
- **Source**: `private/dates.ps1` → **Test**: `Test/private/dates.test.ps1`

The folder structure in `Test/` must exactly match the structure in the main module.

### Test Function Naming
- **Format**: `Test_<FunctionName>_<Scenario>`
- **Examples**:
  - `Test_FindProject_SUCCESS` (success case)
  - `Test_AddProjectUser_SUCCESS_SingleUser` (specific variant)
  - `Test_GetProjectIssue_NotFound` (error case)
- **Conventions**:
  - Use PascalCase matching the actual function name (e.g., `Get-SomeInfo` → `Test_GetSomeInfo_<tip>`)
  - `<tip>` should be a descriptive word indicating the test goal (SUCCESS, NotFound, InvalidInput, etc.)
  - Use assertions: `Assert-IsTrue`, `Assert-Contains`, `Assert-AreEqual`, `Assert-Count`, `Assert-IsNull`

### Mock System
Located in `Test/include/`:
- `invokeCommand.mock.ps1`: Mocks `Invoke-MyCommand` calls via JSON files in `Test/private/mocks/`
- `callPrivateContext.ps1`: Execute private functions in module context

### Mock Data Structure
```powershell
# Test/private/mocks/mockCommands.json defines:
{
  "Command": "Invoke-GetUser -Handle rulasg",
  "FileName": "invoke-GetUser-rulasg.json"
}
```

### Common Test Setup
```powershell
Reset-InvokeCommandMock
Mock_DatabaseRoot
MockCall_GetProject $project -SkipItems
MockCallJson -Command "command" -File "response.json"
```

## Key Dependencies
- **GitHub API**: GraphQL (primary), REST (legacy)
- **TestingHelper**: Test framework from PSGallery
- **InvokeHelper**: Command dispatch/mocking library (external)

## Important Gotchas
1. **Module Loading**: Functions depend on proper load order; new files in `/private` or `/public` auto-loaded
2. **Aliases**: Use `Set-MyInvokeCommandAlias` before calling `Invoke-MyCommand` for consistency
3. **GraphQL Templates**: Fragment files (`.tag`) must match schema; test with actual GitHub API responses
4. **Configuration**: Stored per-module; reset with `Reset-ProjectHelperEnvironment`
5. **PSScriptAnalyzer**: PR checks fail on warnings; review `.github/workflows/powershell.yml` rules

## PR Branch & Active Work
Currently on `projectv2ContributionUpdate` - Implementing project access management with new user collaboration features. Recent changes focus on `Invoke-UpdateProjectV2Collaborators` and `Add-ProjectUser` functions with proper string splitting via `-split` with `[System.StringSplitOptions]::RemoveEmptyEntries`.
