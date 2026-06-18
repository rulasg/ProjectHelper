
Register-StubCommand -Name "Stub_ShowProjectItem" -Description "Show a Project Item with all the speccific fields"

function Stub_ShowProjectItem{
    [CmdletBinding()]
    [Alias("shpi")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][int]$ProjectNumber,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][Alias("M")][switch]$Minimal,
        [Parameter()][Alias("A")][switch]$AllComments,
        [Parameter()][Alias("E")][switch]$OpenInEditor,
        [Parameter()][Alias("W")][switch]$OpenInBrowser,
        [Parameter()][Alias("C")][switch]$NotClearScreen

    )

    begin {
        ($owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber
        $name = "Stub_ShowProjectItem"
    }

    process {

        $parameters = [PsCustomObject] $PsBoundParameters

        $ret = Invoke-StubCommand -Name $name -Owner $Owner -ProjectNumber $ProjectNumber -Parameters $parameters

        return $ret
    }

} Export-ModuleMember -Function Stub_ShowProjectItem -Alias("shpi")

