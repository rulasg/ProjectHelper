

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    # so far we only check if the database exists
    # TODO check if the database has expired
    return Test-Database -Owner $Owner -ProjectNumber $ProjectNumber
} 

function Update-ProjectDatabase {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $items = Get-ItemsList -Owner $Owner -ProjectNumber $ProjectNumber
    $fields = Get-FieldList -Owner $Owner -ProjectNumber $ProjectNumber

    Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Items $items -Fields $fields
}

function Get-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    if($force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)){
        Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
    }

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    return $db
}