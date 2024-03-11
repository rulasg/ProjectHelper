
$script:EnvironmentCache_Owner = $null
$script:EnvironmentCache_ProjectNumber = $null
$script:EnvironmentCache_Display_Fields = @()
$DEFAULT_DISPLAY_FIELDS = @("id","title")


function Get-OwnerAndProjectNumber{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )
    if([string]::IsNullOrWhiteSpace($Owner)){
        $owner =$script:EnvironmentCache_Owner
    } else {
        $script:EnvironmentCache_Owner = $Owner
    }

    if([string]::IsNullOrWhiteSpace($ProjectNumber)){
        $ProjectNumber =$script:EnvironmentCache_ProjectNumber
    } else {
        $script:EnvironmentCache_ProjectNumber = $ProjectNumber
    }

    return ($owner, $ProjectNumber)
}

function Get-EnvironmentDisplayFields{
    [CmdletBinding()]
    param(
        [Parameter()][string[]]$Fields
    )

    $fields_Options = ($Fields , $script:EnvironmentCache_Display_Fields , $DEFAULT_DISPLAY_FIELDS)
    
    foreach($option in $fields_Options){
        if ( -Not $option.Count -eq 0) {
            $script:EnvironmentCache_Display_Fields = $option
            $ret = $option
            break
        }
    }

    $ret = $DEFAULT_DISPLAY_FIELDS + $ret

    # remove duplicates
    $ret = $ret | Select-Object -Unique

    return $ret
}