function Get-RepoOwnerNameNumberFromUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Url
    )

    $uri = [System.Uri]$Url

    $owner = $uri.Segments[1].TrimEnd('/')
    $repoName = $uri.Segments[2].TrimEnd('/')

    #if segments[4] is present get the number
    if($uri.Segments[4]){
        $number = $uri.Segments[4].TrimEnd('/')
    }

    return $owner, $repoName, $number
}