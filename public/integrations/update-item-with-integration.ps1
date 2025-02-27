
function Update-ProjectItemFields {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][hashtable]$Values,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ProjectCO,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$ItemCO
    )

    $item = Get-ProjectItem


    return $integrationCall

} Export-ModuleMember -Function Update-ItemWithIntegration

function Update-ItemWithIntegration_POC{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$ProjectNumber
    )
    ($Owner,$ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber
    if([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber)){ "Owner and ProjectNumber are required" | Write-MyError; return $null}

    # Get project
    $items = Get-ProjectItemList -owner $Owner -ProjectNumber $ProjectNumber


    # List the items that have the integration ID
    $items
} Export-ModuleMember -Function Update-ItemWithIntegration_POC