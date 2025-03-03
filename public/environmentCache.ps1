
$DEFAULT_DISPLAY_FIELDS = @("id","title")

function Get-ProjectEnvironment{
    [CmdletBinding()]
    param()

    $ret = @{

        Owner = Get-EnvItem -Name EnvironmentCache_Owner
        ProjectNumber = Get-EnvItem -Name "EnvironmentCache_ProjectNumber"
        DisplayFields = Get-EnvItem -Name "EnvironmentCache_Display_Fields"
    }
    
    return $ret

} Export-ModuleMember -Function Get-ProjectEnvironment

function Get-OwnerAndProjectNumber{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    if([string]::IsNullOrWhiteSpace($Owner)){
        $owner = Get-EnvItem -Name "EnvironmentCache_Owner"
    } else {
        Set-EnvItem -Name "EnvironmentCache_Owner" -Value $Owner
    }

    if([string]::IsNullOrWhiteSpace($ProjectNumber)){
        $ProjectNumber = Get-EnvItem -Name "EnvironmentCache_ProjectNumber"
    } else {
        Set-EnvItem -Name "EnvironmentCache_ProjectNumber" -Value $ProjectNumber
    }

    return ($owner, $ProjectNumber)
} Export-ModuleMember -Function Get-OwnerAndProjectNumber

function Get-EnvironmentDisplayFields{
    [CmdletBinding()]
    param(
        [Parameter()][string[]]$Fields
    )

    $displayFields = Get-EnvItem -Name "EnvironmentCache_Display_Fields"
    $defaultDisplayFields = Get-DefaultDisplayFields
    $fields_Options = ($Fields , $displayFields , $defaultDisplayFields)

    # chos ethe first that is not empty
    foreach($option in $fields_Options){
        if ( -Not $option.Count -eq 0) {
            Set-EnvItem -Name "EnvironmentCache_Display_Fields" -Value $option
            $ret = $option
            break
        }
    }

    $ret = $defaultDisplayFields + $ret

    # remove duplicates
    $ret = $ret | Select-Object -Unique

    return $ret
}

function Get-EnvItem{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Name
    )

    $ret = Get-Database -Key $Name

    # $ret = Get-Variable -Name $Name -ValueOnly -Scope Script


    return $ret

}

function Set-EnvItem{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Name,
        [Parameter(Position=1)][object]$Value
    )

    # Set-Variable -Name $Name -Value $Value -Scope Script

    Save-Database -Key $Name -Database $Value

}

function Get-DefaultDisplayFields{
    [CmdletBinding()]
    param()

    # return Get-EnvItem -Name "EnvironmentCache_Display_Fields"
    return $DEFAULT_DISPLAY_FIELDS
} 