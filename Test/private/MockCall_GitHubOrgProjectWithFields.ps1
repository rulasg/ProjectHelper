
function MockCall_GitHubOrgProjectWithFields {
    Param(
        [string]$Owner,
        [string]$ProjectNumber,
        [string]$FileName,
        [switch]$SkipItems
    )

    $cmdName = $SkipItems ? "GitHubOrgProjectWithFieldsSkipItems" : "GitHubOrgProjectWithFields"

    $cmd = ((Get-InvokeCommandAliasList).$cmdName).Command
    $cmd = $cmd -replace '{owner}', $Owner
    $cmd = $cmd -replace '{projectnumber}', $ProjectNumber
    $cmd = $cmd -replace '{afterFields}', ""
    $cmd = $cmd -replace '{afterItems}', ""

    # Check if filename contains "skipitems" and throw error if it doesn't
    if ( $SkipItems -and $FileName -notlike '*skipitems*') {
        throw "Filename must contain 'skipitems'. Please rename the file or use a different file."
    }

    MockCallJson -Command $cmd -Filename $FileName
}

function MockCall_GitHubOrgProjectWithFields_Null {
    Param(
        [string]$Owner,
        [string]$ProjectNumber
    )

    $cmd = ((Get-InvokeCommandAliasList)."GitHubOrgProjectWithFields").Command
    $cmd = $cmd -replace '{owner}', $Owner
    $cmd = $cmd -replace '{projectnumber}', $ProjectNumber
    $cmd = $cmd -replace '{afterFields}', ""
    $cmd = $cmd -replace '{afterItems}', ""

    MockCalltoNull -Command $cmd
}