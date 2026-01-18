
Set-MyInvokeCommandAlias -Alias createDraftItem -Command 'Invoke-CreateDraftItem -ProjectId {projectid} -Title "{title}" -Body "{body}"'


function New-ProjectDraftIssueDirect {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Owner,
        [Parameter()][string] $ProjectNumber,
        [Parameter(Mandatory,Position=0)][string]$Title,
        [Parameter(Position=1)][string]$Body,
        [Parameter()][switch]$NoCache,
        [Parameter()][switch]$OpenOnCreation
    )

    ($Owner, $ProjectNumber) = Get-OwnerAndProjectNumber -Owner $Owner -ProjectNumber $ProjectNumber

    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber

    $params = @{
        title       = $Title | ConvertTo-InvokeParameterString
        body        = $Body | ConvertTo-InvokeParameterString
        projectid   = $db.ProjectId
    }

    $params | ConvertTo-Json | Write-Verbose

    $response = Invoke-MyCommand -Command "createDraftItem" -Parameters $params

    $item = $response.data.addProjectV2DraftIssue.projectItem

    if ($item) {
        $ret = $item.id

        if (! $NoCache) {
            "Adding item [$ret] to cache" | Write-Verbose

            $item = $item | Convert-NodeItemToHash

            Set-Item $db $item

            Save-ProjectDatabaseSafe -Database $db

        }

        if( $OpenOnCreation ) {
            Open-Url $item.url
        }

        return $ret

    }
    else {
        "Item not added to project" | Write-MyError
        return $null
    }

} Export-ModuleMember -Function New-ProjectDraftIssueDirect
