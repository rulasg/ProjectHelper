
$script:EnvironmentCache_Owner = $null
$script:EnvironmentCache_ProjectNumber = $null

function Get-OwnerAndProjectNumber{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )
    if([string]::IsNullOrWhiteSpace($Owner)){
        $owner =$script:EnvironmentCache_Owner
    } else {
        $script:EnvironmentCache_Owner = $Owner
    }

    if([string]::IsNullOrWhiteSpace($ProjectNumber)){
        $ProjectNumber =$script:EnvironmentCache_ProjectNumber
    } else {
        $script:EnvironmentCache_ProjectNumber = $ProjectNumber
    }

    return ($owner, $ProjectNumber)
}