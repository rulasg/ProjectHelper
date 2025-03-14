
function MockCall_GitHubOrgProjectWithFields{
    Param(
        [string]$Owner,
        [string]$ProjectNumber,
        [string]$FileName
    )

    $cmd = ((Get-InvokeCommandAliasList)."GitHubOrgProjectWithFields").Command
    $cmd = $cmd -replace '{owner}', $Owner
    $cmd = $cmd -replace '{projectnumber}', $ProjectNumber
    $cmd = $cmd -replace '{afterFields}', ""
    $cmd = $cmd -replace '{afterItems}', ""

    # MockCallJson -Command $cmd -Filename "invoke-GitHubOrgProjectWithFields-$Owner-$ProjectNumber.2.json"
    MockCallJson -Command $cmd -Filename $FileName
}

function MockCall_GitHubOrgProjectWithFields_Null{
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