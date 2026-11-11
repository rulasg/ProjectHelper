# ProjectHelper

A powershell module that will hold Powershell functionality.

> Module generated with [TestingHelper Powershell Module](https://www.powershellgallery.com/packages/TestingHelper/)

## Issue dependencies

Mark one project item as blocked by another:

```powershell
Add-ProjectItemBlocked -ItemId PVTI_blocked -BlockingItemId PVTI_blocker -Owner my-org -ProjectNumber 123
```

`ItemId` is the blocked item; `BlockingItemId` is its blocker. Both must be
GitHub issues in the selected project (not drafts or pull requests). Owner and
project number can also come from the current project context. Pipe blocker item
IDs to create multiple relationships. The function returns `$true` for each
successful relationship and logs an error and returns `$null` on failure.

Uses GitHub's documented [`addBlockedBy` GraphQL mutation](https://docs.github.com/en/graphql/reference/issues#addblockedby---mutation)
with the underlying issue node IDs, not the project item IDs.
