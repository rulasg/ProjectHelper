function Get-Project{
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

    $prj = Get-ProjectFromDatabase -Owner $Owner -ProjectNumber $ProjectNumber

    return $prj
} Export-ModuleMember -Function Get-Project