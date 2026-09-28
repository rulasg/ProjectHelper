
# Retrieve all the Tags used on titles excluding the ones that specify the repo name
function Get-ProjectItemTitleTag{
    [CmdletBinding()]
    [Alias("gptt","gtt")]
    param(
        [Parameter()][string]$Filter,
        [Parameter()][switch]$IncludeDone
    )

    $items = Get-ProjectItems -IncludeDone:$IncludeDone

    $tagList = @()

    foreach($item in $items){
        
        # Filter Draft items
        if (-not $item.RepositoryName) {
            continue
        } else {
            $repoName = $item.RepositoryName.ToLower()
        }

        $title = $item.Title
        
        $tags = $title | Get-TagFromString
        if($tags.Count -ne 0){
            $tags = $tags | Where-Object { $_.ToLower() -ne $repoName }
            $tagList += $tags
        }
    }

    $tagList = $tagList | Sort-Object -Unique

    if ($Filter) {
        $tagList = $tagList | Where-Object { $_ -like "*$Filter*" }
    }

    return $tagList

} Export-ModuleMember -Function Get-ProjectItemTitleTag -alias "gptt","gtt"

function Search-ProjectItemsWithTag{
    [CmdletBinding()]
    [Alias ("spitt","stt")]
    param(
        [Parameter()][string[]]$Filter,
        [Parameter()][string[]]$Attributes,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$IncludeDone,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$PassThru,
        [Parameter()][string]$FieldName,
        [Parameter()][switch]$AnyField,
        [Parameter()][switch]$Exact,
        
        # Repository
        [Parameter()][string]$RepositoryName,
        [Parameter()][string]$RepositoryOwner,

        # tag
        [Parameter(Mandatory,Position = 0)][string]$TagName
    )

    $params =@{
        Filter = $Filter
        Attributes = $Attributes
        Owner = $Owner
        ProjectNumber = $ProjectNumber
        IncludeDone = $IncludeDone
        Force = $Force
        PassThru = $PassThru
        FieldName = $FieldName
        AnyField = $AnyField
        Exact = $Exact
        RepositoryName = $RepositoryName
        RepositoryOwner = $RepositoryOwner
    }

    $items = Search-ProjectItem @params

    $ret = $items | Where-Object {Test-TagOnString -String $_.Title -Tag $TagName -Exact:$Exact }

    return $ret

} Export-ModuleMember -Function Search-ProjectItemsWithTag -alias "spitt","stt"