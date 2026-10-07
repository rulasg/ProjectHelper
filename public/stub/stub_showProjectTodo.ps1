
Register-StubCommand -Name "Stub_ShowProjectTodo" -Description "Show the Project Todo list"

function  Stub_ShowProjectTodo{
    [CmdletBinding()]
    [alias ("spit","Show-ProjectTodo")]
    param(
        # owner and project number 
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        
        [Parameter(Position=0)][Alias("T")][string]$Title,
        
        [Parameter()][Alias("Pt")][switch]$Passthru,
        [Parameter()][Alias("F")][switch]$Force,
        [Parameter()][Alias("C")][switch]$ClearScreen,
        
        [Parameter()][Alias("N")][Int]$MaxNumber = 30,
        [Parameter()][Alias("A")][switch]$All,
        
        # Ordinal
        [Parameter()][Alias("O")][int]$Ordinal = -1,

        # Status
        [parameter()][Alias("S")][string[]]$Status,

        # Attributes
        [parameter()][Alias("Att")][string[]]$Attributes
    )

    begin {
        ($owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber
        $name = "Stub_ShowProjectTodo"
    }

    process {

        $parameters = [PsCustomObject] $PsBoundParameters

        $ret = Invoke-StubCommand -Name $name -Owner $Owner -ProjectNumber $ProjectNumber -Parameters $parameters

        return $ret
    }

} Export-ModuleMember -Function Stub_ShowProjectTodo -Alias "spit", "Show-ProjectTodo"