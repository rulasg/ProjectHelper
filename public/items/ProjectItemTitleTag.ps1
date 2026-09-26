function Add-ProjectItemTitleTag{
    [CmdletBinding()]
    [alias("apitt","att")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("ProjectOwner")][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 0)][Alias("T")][string]$TagName,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)][Alias("ItemId")][string]$Id,
        [Parameter()][switch]$End
    )

    process {
        
        # Resolve the Project
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

        # Resolve the ItemId
        $Id = Resolve-ProjectItemId -ItemId $Id

        # Get Item
        $item = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $Id

        $title = $item.Title

        "Add Title Tag [$TagName] to Item [$Id]" | Write-MyDebug -Section "TitleTag"
        
        $newTitlte = $title  | Add-TagToString $TagName -End:$End

        "Old Title: '$title' --> New Title: '$newTitlte'" | Write-MyDebug -Section "TitleTag"

        Edit-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $Id -Title $newTitlte
    }

} Export-ModuleMember -Function Add-ProjectItemTitleTag -alias "apitt","att"

function Remove-ProjectItemTitleTag{
    [CmdletBinding()]
    [alias("rpitt","rtt")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("ProjectOwner")][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ProjectNumber,
        [Parameter(Mandatory,Position = 0)][Alias("T")][string]$TagName,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)][Alias("ItemId")][string]$Id
    )

    process {

        # Resolve the Project
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

        # Resolve the ItemId
        $Id = Resolve-ProjectItemId -ItemId $Id

        # Get Item
        $item = Get-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $Id

        $title = $item.Title

        "Remove Title Tag [$TagName] from Item [$Id]" | Write-MyDebug -Section "TitleTag"
        
        $newTitlte = $title  | Remove-TagFromString $TagName

        "Old Title: '$title' --> New Title: '$newTitlte'" | Write-MyDebug -Section "TitleTag"

        Edit-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $Id -Title $newTitlte
    }

} Export-ModuleMember -Function Remove-ProjectItemTitleTag -alias "rpitt","rtt"

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
            $repo = $item.RepositoryName.ToLower()
        }

        $title = $item.Title
        
        $tags = $title | Get-TagFromString
        $tags = $tags | Where-Object { $_.ToLower() -notlike "*$repo*" }
        $tagList += $tags
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