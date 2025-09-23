
$DEFAULT_DISPLAY_FIELDS = @("id","title")

function Get-ProjectHelperEnvironment{
    [CmdletBinding()]
    param()

    $ret = @{

        # Last Known Good Owner
        Owner         = Get-EnvItem -Name "EnvironmentCache_Owner"
        # Last Known Good Project Number
        ProjectNumber = Get-EnvItem -Name "EnvironmentCache_ProjectNumber"
        # List of fields to display on Items display commands. Useful with ConvertToItemDisplay
        # TODO : Consider if its worth keeping this setting
        DisplayFields = Get-EnvItem -Name "EnvironmentCache_Display_Fields"
    }

    return $ret

} Export-ModuleMember -Function Get-ProjectHelperEnvironment

function Reset-ProjectHelperEnvironment{
    [CmdletBinding()]
    param()

    Set-EnvItem -Name "EnvironmentCache_Owner" -Value $null
    Set-EnvItem -Name "EnvironmentCache_ProjectNumber" -Value $null
    Set-EnvItem -Name "EnvironmentCache_Display_Fields" -Value $null

} Export-ModuleMember -Function Reset-ProjectHelperEnvironment

function Set-ProjectHelperEnvironment{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string[]]$DisplayFields
    )

    if(! [string]::IsNullOrWhiteSpace($Owner)) {
        Set-EnvItem -Name "EnvironmentCache_Owner" -Value $Owner
    }

    if(! [string]::IsNullOrWhiteSpace($ProjectNumber)) {
        Set-EnvItem -Name "EnvironmentCache_ProjectNumber" -Value $ProjectNumber
    }
    if($DisplayFields) {
        Set-EnvItem -Name "EnvironmentCache_Display_Fields" -Value $DisplayFields
    }

} Export-ModuleMember -Function Set-ProjectHelperEnvironment

function Get-OwnerAndProjectNumber{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    if($ProjectNumber -eq "0"){
        $ProjectNumber = [string]::Empty
    }

    $ownerCache = Get-EnvItem -Name "EnvironmentCache_Owner"
    if([string]::IsNullOrWhiteSpace($Owner)){
        $owner = $ownerCache
    } else {
        if($owner -ne $ownerCache){
            Set-EnvItem -Name "EnvironmentCache_Owner" -Value $Owner
        }
    }
 
    $projectNumberCache = Get-EnvItem -Name "EnvironmentCache_ProjectNumber"
    if([string]::IsNullOrWhiteSpace($ProjectNumber)){
        $ProjectNumber = $projectNumberCache
    } else {
        if($ProjectNumber -ne $projectNumberCache){
            Set-EnvItem -Name "EnvironmentCache_ProjectNumber" -Value $ProjectNumber
        }
    }

    return ($owner, $ProjectNumber)
}

function Get-EnvironmentDisplayFields{
    [CmdletBinding()]
    param(
        [Parameter()][string[]]$Fields
    )

    $displayFields = Get-EnvItem -Name "EnvironmentCache_Display_Fields"
    # Use this order
    $fields_Options = @()
    if ($DEFAULT_DISPLAY_FIELDS) { $fields_Options += $DEFAULT_DISPLAY_FIELDS }
    if ($Fields) { $fields_Options += $Fields }
    if ($displayFields) { $fields_Options += $displayFields }

    # Remove nulls empty and duplicates
    $ret = $fields_Options | Select-Object -Unique | Where-Object {-Not [string]::IsNullOrWhiteSpace($_)}

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
