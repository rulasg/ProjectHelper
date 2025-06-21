function Get-RepoOwnerNumberFromUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Url
    )

    $uri = [System.Uri]$Url

    $owner = $uri.Segments[1].TrimEnd('/')
    $repoName = $uri.Segments[2].TrimEnd('/')
    $number = $uri.Segments[4].TrimEnd('/')

    return $owner, $repoName, $number
} Export-ModuleMember -Function Get-RepoOwnerNumberFromUrl