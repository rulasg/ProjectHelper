function Resolve-ProjectParameters {
    [CmdletBinding()]
    param(
            [Parameter(Position = 0)][string]$ProjectNumber,
            [Parameter(Position = 1)][string]$Owner,
            [Parameter()][switch]$DoNotThrow

        )

        if($ProjectNumber -eq 0){
            $ProjectNumber = ""
        }

        if([string]::IsNullOrWhiteSpace($Owner)){
            $Owner = Get-EnvItem -Name "env-owner"
        }

        if([string]::IsNullOrWhiteSpace($ProjectNumber)){
            $ProjectNumber = Get-EnvItem -Name "env-ProjectNumber"
        }

        if([string]::IsNullOrWhiteSpace($ProjectNumber) -or [string]::IsNullOrWhiteSpace($Owner)){
            if(-Not $DoNotThrow){
                throw "Owner and ProjectNumber parameters are required. Please provide them as parameters or set them in the environment cache."
            } else {
                Write-MyDebug "Owner or ProjectNumber is missing. Returning null values." -Section "Resolve-ProjectParameters"
                return ($null, $null)
            }
        }

        return ($Owner, $ProjectNumber)
}

function Test-ProjectParameters {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$ProjectNumber,
        [Parameter(Position = 1)][string]$Owner
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber -DoNotThrow

    return -not ([string]::IsNullOrWhiteSpace($Owner) -or [string]::IsNullOrWhiteSpace($ProjectNumber))
}

function Set-ProjectParameters {
    [CmdletBinding()]
    [Alias("Set-Project","spp")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 0)][string]$Owner,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)][string]$ProjectNumber
    )

    process {
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -ErrorAction SilentlyContinue

        if($db){
            $ProjectTitle = $db.title
        }

        Set-ProjectHelperEnvironment -Owner $Owner -ProjectNumber $ProjectNumber -ProjectTitle $ProjectTitle
    }

} Export-ModuleMember -Function Set-ProjectParameters -Alias "Set-Project","spp"

function Get-ProjectParameters {
    [CmdletBinding()]
    [Alias("gpp")]
    param()

    $result =Get-ProjectHelperEnvironment

    $ret = @{
        Owner = $result.Owner
        ProjectNumber = $result.ProjectNumber
        ProjectTitle = $result.ProjectTitle
    }
    $ret.Owner = $result.Owner
    $ret.ProjectNumber = $result.ProjectNumber
    
    $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -ErrorAction SilentlyContinue -skipItems

    $ret.ProjectTitle = $db.title

    return $ret

} Export-ModuleMember -Function Get-ProjectParameters -Alias "gpp"