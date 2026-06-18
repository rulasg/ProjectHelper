function Invoke-StubCall{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $stubName,
        [Parameter(Mandatory)][hashtable] $Parameters
    )

    $retString = "Param1: '$($Parameters.Str1)', Param2: '$($Parameters.Bool1)', Param3: '$($Parameters.Switch1)', Param4: '$($Parameters.Hash1.Keys -join ',')'"

    switch ($stubName) {
        "Stub_Test" { $ret = $retString }
        default { throw "Unknown stub name: $stubName" }
    }

    return $ret

} Export-ModuleMember -Function Invoke-StubCall