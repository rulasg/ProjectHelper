# Database driver to store and cacche project content and schema

$script:PROJECT_DATABASE_LIST = @{}

function New-Database{
    return [PSCustomObject]@{
        Items = $null
        Fields = $null
    }
}

function Reset-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
        )
    
        $db = New-Database

        $script:PROJECT_DATABASE_LIST."$owner/$projectnumber" = $db

}

function Get-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
        )

        if( -Not (Test-Database -Owner $Owner -ProjectNumber $ProjectNumber)){
           Reset-Database -Owner $Owner -ProjectNumber $ProjectNumber
        }

        return $script:PROJECT_DATABASE_LIST."$owner/$projectnumber"
    }

function Test-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber
    )

    $db = $script:PROJECT_DATABASE_LIST."$owner/$projectnumber"

    if($null -eq $db){
        return $false
    }

    if($null -eq $db.Items){
        return $false
    }

    if($null -eq $db.Fields){
        return $false
    }

    return $true
}

function Set-Database{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Owner,
        [Parameter(Position = 1)][int]$ProjectNumber,
        [Parameter(Position = 2)][Object[]]$Items,
        [Parameter(Position = 3)][Object[]]$Fields
    )

    $db = Get-Database -Owner $Owner -ProjectNumber $ProjectNumber

    $db.items = $items
    $db.fields = $fields
}