function Update-ProjectItemStatusOnCondition{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter(Position = 2)][string]$Status,
        [Parameter(Position = 3)][string]$Condition,
        [Parameter()][switch]$Force
    )

    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    $prj = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    # Find items with condition

    # Update status on items


} Export-ModuleMember -Function Update-ProjectItemStatusOnCondition