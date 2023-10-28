
function Get-ProjectItems{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("gghpi")]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter()][int32]$ProjectNumber = -1
    )

    process {

        # Resolve ProjectNumber
        if($ProjectNumber -ne -1){
            $projectNumberParam = $ProjectNumber
            $ownerParam = $Owner

        } else{
            # Resolve ProjectNumber from Environment
            $env = Resolve-EnvironmentProject -Owner $Owner -ProjectTitle $ProjectTitle;

            if($env.ProjectNumber -eq -1){
                "Wrong project parameters please try again" | Write-Error
            } else {
                $projectNumberParam = $env.ProjectNumber
                $ownerParam = $env.Owner
            }
        } 

        #Build Command
        $command = Build-Command -CommandKey 'Project_Item_List' -Owner $ownerParam -ProjectNumber $projectNumberParam
        
        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpressionToJson -Command $command
        } else {
            $command | Write-Information
        }

        # Error checking

        # Transform o$result into a PowerShell object

        # return
        return $result
    }
} Export-ModuleMember -Function Get-ProjectItems -Alias gghpi

function Add-ProjectItem {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][Alias("Url")][string]$IssueUrl
    )

    process {
        # Environment
        $env = Resolve-EnvironmentProject -Owner $Owner -ProjectTitle $ProjectTitle; if(!$env){return $null}

        # Build Expression
        $command = Build-Command -CommandKey Project_Item_Add -Owner $env.Owner -ProjectNumber $env.ProjectNumber -Url $IssueUrl
        # $command = $commandPattern -f $env.ProjectNumber, $env.Owner, $IssueUrl

        # Invoke Expression
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            $result = Invoke-GhExpression -Command $command
        }

        # Error checking

        # Transform

        # Return
        return $result
    }
        
} Export-ModuleMember -Function Add-ProjectItem -Alias aghpi

function Remove-ProjectrojectItem { # scratch
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

} Export-ModuleMember -Function Remove-ProjectrojectItem -Alias rghpi

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