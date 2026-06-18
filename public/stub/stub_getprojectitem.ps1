
Register-StubCommand -Name "Stub_GetProjectItem" -Description "Get a Project Item with all the speccific fields"

function  Stub_GetProjectItem{
    [CmdletBinding()]
    [alias ("gpi","Get-ProjectItem")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    begin {
        ($owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber
        $name = "Stub_GetProjectItem"
    }

    process {

        $parameters = [PsCustomObject] $PsBoundParameters

        $ret = Invoke-StubCommand -Name $name -Owner $Owner -ProjectNumber $ProjectNumber -Parameters $parameters

        return $ret
    }

} Export-ModuleMember -Function Stub_GetProjectItem -Alias "gpi", "Get-ProjectItem"