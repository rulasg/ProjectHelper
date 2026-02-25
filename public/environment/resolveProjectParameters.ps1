function Resolve-ProjectParameters {
    [CmdletBinding()]
    param(
            [Parameter(Position = 0)][string]$ProjectNumber,
            [Parameter(Position = 1)][string]$Owner
        )

        if([string]::IsNullOrWhiteSpace($Owner)){
            $Owner = Get-EnvItem -Name "EnvironmentCache_Owner"
        }

        if([string]::IsNullOrWhiteSpace($ProjectNumber)){
            $ProjectNumber = Get-EnvItem -Name "EnvironmentCache_ProjectNumber"
        }

        if([string]::IsNullOrWhiteSpace($ProjectNumber) -or [string]::IsNullOrWhiteSpace($Owner)){
            throw "Owner and ProjectNumber parameters are required. Please provide them as parameters or set them in the environment cache."
        }

        return ($Owner, $ProjectNumber)
    
}