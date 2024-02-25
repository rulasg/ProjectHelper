

function Get-ProjectItems{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [int]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    $db = Get-ProjectDatabase -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    return $db.items

} Export-ModuleMember -Function Get-ProjectItems





function Edit-ProjectrojectItem { # scratch
    [CmdletBinding()]
    param (
        [Parameter()][string]$ProjectId,
        [Parameter()][string]$ItemId,
        [Parameter()][string]$FieldId,
        [Parameter()][string]$TextValue
    )
    
    # gh project item-edit --project-id PVT_kwHOAGkMOM4AUB10 --id PVTI_lAHOAGkMOM4AUB10zgIiBZs --field-id PVTF_lAHOAGkMOM4AUB10zgM0BvM

    
    begin {}
    
    process{
        
        gh project item-edit --project-id $ProjectId --id $ItemId --field-id $FieldId --text $TextValue
        
        # Environment
        
        # Build Expression
        
        # Invoke Expression
        
        # Error checking
        
        # Transform
        
        # Return
    }

} Export-ModuleMember -Function Edit-ProjectrojectItem -Alias eghpi