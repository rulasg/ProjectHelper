
function Get-GhPItems{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("gghpi")]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber
    )

    process {
        # # Get default values from Environment
        # $Owner = Find-GhPOwnerFromEnvironment -Owner $Owner ; if(!$Owner){return $null}
        # $ProjectTitle = Find-GhProjectTitleFromEnvironment($ProjectTitle) ; if(!$ProjectTitle){return $null}
        # [int]$ProjectNumber = Get-GhProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner ; if($ProjectNumber -eq -1){return $null}

        $env = Resolve-GhPEnviroment -Owner $Owner -ProjectTitle $ProjectTitle; if(!$env){return $null}
        
        # Build expression
        $commandPattern_Item_List = 'gh project item-list {0} --owner "{1}"'
        $command = $commandPattern_Item_List -f $env.ProjectNumber, $env.Owner
        
        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpression -Command $command
        } else {
            $command | Write-Information
        }
        
        # Error checking

        # Transform o$result into a PowerShell object
        
        # return
        return $result
    }
} Export-ModuleMember -Function Get-GhPItems -Alias gghpi

function Add-GhPItem {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][Alias("Url")][string]$IssueUrl
    )

    begin{
        # gh project item-add $ProjectNumber --owner $owner --url $IssueUrl
        $commandPattern = 'gh project item-add {0} --owner {1} --url {2}'
    }

    process {
        # Environment
        # $Owner = Find-GhPOwnerFromEnvironment -Owner $Owner ; if(!$Owner){return $null}
        # $ProjectTitle = Find-GhProjectTitleFromEnvironment -ProjectTitle $ProjectTitle ; if(!$ProjectTitle){return $null}
        # [int]$ProjectNumber = Get-GhProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner ; if($ProjectNumber -eq -1){return $null}
        $env = Resolve-GhPEnviroment -Owner $Owner -ProjectTitle $ProjectTitle; if(!$env){return $null}

        # Build Expression
        $command = $commandPattern -f $env.ProjectNumber, $env.Owner, $IssueUrl

        # Invoke Expression
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            $result = Invoke-GhExpression -Command $command
        }

        # Error checking

        # Transform

        # Return
        return $result
    }
        
} Export-ModuleMember -Function Add-GhPItem -Alias aghpi

function Remove-GhProjectItem { # scratch
    [CmdletBinding()]
    param (
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ItemId
    )
    
    begin {}

    process{

        gh project item-delete $ProjectNumber --owner $owner --id $ItemId
        
        # Environment
        
        # Build Expression
        
        # Invoke Expression
        
        # Error checking
        
        # Transform
        
        # Return
    }

} Export-ModuleMember -Function Remove-GhProjectItem -Alias rghpi

function Edit-GhProjectItem { # scratch
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

} Export-ModuleMember -Function Edit-GhProjectItem -Alias eghpi