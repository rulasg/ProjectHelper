

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

function Test-ProjectDatabaseStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    # Check if there is content Staged and not commited yet
    return Test-DatabaseStaged -Owner $Owner -ProjectNumber $ProjectNumber
}

function Get-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    if($force -or -Not (Test-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber)){
        $result = Update-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber
        if( ! $result){ return }
    }

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    return $db
}

function Reset-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    Reset-Database -Owner $Owner -ProjectNumber $ProjectNumber
}


