

function Test-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    $ret = $null -ne $db

    return $ret 
}

function Test-ProjectDatabaseStaged{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    if($null -eq $db){
        return $false
    }

    if($null -eq $db.Staged){
        return $false
    }

    if($db.Staged.Count -eq 0){
        return $false
    }

    return $true
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
} Export-ModuleMember -Function Get-ProjectDatabase

function Reset-ProjectDatabase{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Database $null
}

# function Set-ProjectDatabase{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][string]$Owner,
#         [Parameter(Position = 1)][int]$ProjectNumber,
#         [Parameter(Position = 2)][Object[]]$Items,
#         [Parameter(Position = 3)][Object[]]$Fields
#     )

#     $db = New-ProjectDatabase

#     $db.items = $items
#     $db.fields = $fields

#     Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Database $db
# }

function Set-ProjectDatabaseV2{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][object]$Response,
        [Parameter(Position = 1)][Object[]]$Items,
        [Parameter(Position = 2)][Object[]]$Fields
    )

    $projectV2 = $Response.data.organization.ProjectV2

    $owner = $ProjectV2.owner.login
    $projectnumber = $ProjectV2.number

    $db = @{}
    
    $db.url              = $ProjectV2.url
    $db.shortDescription = $ProjectV2.shortDescription
    $db.public           = $ProjectV2.public
    $db.closed           = $ProjectV2.closed
    $db.title            = $ProjectV2.title
    $db.id               = $ProjectV2.id
    $db.readme           = $ProjectV2.readme
    $db.owner            = $ProjectV2.owner
    $db.number           = $ProjectV2.number

    $db.items = $items
    $db.fields = $fields
    
    Set-Database -Owner $Owner -ProjectNumber $ProjectNumber -Database $db
}
