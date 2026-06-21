
Register-StubCommand -Name "Stub_ShowProjectTodo" -Description "Show the Project Todo list"

function  Stub_ShowProjectTodo{
    [CmdletBinding()]
    [alias ("spit","Show-ProjectTodo")]
    param(
        # owner and project number 
        [Parameter()][Alias("O")][string]$Owner,
        [Parameter()][Alias("P")][string]$ProjectNumber,
        
        [Parameter()][Alias("t")][string]$Title,
        
        [Parameter()][Alias("pt")][switch]$Passthru,
        [Parameter()][Alias("f")][switch]$Force,
        [Parameter()][Alias("c")][switch]$ClearScreen,
        
        [Parameter()][Alias("n")][Int]$MaxNumber = 30,
        [Parameter()][Alias("a")][switch]$All,
        
        # Ordinal
        [Parameter(Position=0)][int]$Ordinal = -1,

        # Status
        [parameter()][Alias("s")][string[]]$Status,

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