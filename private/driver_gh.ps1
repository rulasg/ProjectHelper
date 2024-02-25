Set-MyInvokeCommandAlias -Alias GetProjectItems -Command 'gh project item-list {projectnumber} --owner {owner} --format json'
Set-MyInvokeCommandAlias -Alias GetProjectFields -Command 'gh project field-list {projectnumber} --owner {owner} --format json'

function Get-ItemsList {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }

    # Items
    $result  = Invoke-MyCommandJsonAsync -Command GetProjectItems -Parameters $params

    # check for errors

    return $result.Items
}

function Get-FieldList {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $params = @{ owner = $Owner ; projectnumber = $ProjectNumber }

    # Fields
    $result  = Invoke-MyCommandJsonAsync -Command GetProjectFields -Parameters $params

    # check for errors

    return $result.Fields
}