
Set-MyInvokeCommandAlias -Alias GetItemId -Command 'Invoke-GetItemId -Url {url}'

function Get-ItemIdFromUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Url,
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber

    )

    # figure out the projectID from environment
    if([string]::IsNullOrWhiteSpace($ProjectId)){
        $project = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -SkipItems
        if(-not $project){
            "Project not found for Owner [$Owner] and ProjectNumber [$ProjectNumber]" | Write-MyError
            return $null
        }
        $projectId = $project.ProjectId
    }

    $params = @{
        url = $Url
    }

    $response = Invoke-MyCommand -Command GetItemId -Parameters $params

    $nodes = $response.data.repository.issueOrPullRequest.projectItems.nodes

    if(-not $nodes){
        "Query failed" | Write-MyError
        $ret = $null
    }

    # find the project reference in the nodes
    $node = $nodes | Where-Object { $_.project.id -eq $projectId }

    if($node){
        $ret = $node.id
    } else {
        "Item not found for URL [$Url] on project with Owner [$Owner] ProjectNumber [$ProjectNumber] ProjectId [$projectId]" | Write-MyError
        $ret = $null
    }

    return $ret
} Export-ModuleMember -Function Get-ItemIdFromUrl