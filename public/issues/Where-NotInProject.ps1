function Find-NotInProject {
    [CmdletBinding()]
    [Alias("wsp","Where-SalesProject")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(ValueFromPipeline, Position=0)][object[]]$ItemWithUrl,
        [Parameter()][switch]$All
    )

    begin{
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber
    }

    process{

        $fildname = "isMember"

        $ItemWithUrl | ForEach-Object {
            $url = $_.url

            $i = [string]::IsNullOrWhiteSpace($url) ? $null : $(Get-ProjectItemByUrl -Owner $Owner -ProjectNumber $ProjectNumber -Url $url -ErrorAction SilentlyContinue)

            if($All){
                if($_ -is [hashtable]){
                    $_[$fildname] = $null -ne $i
                } else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name $fildname -Value ($null -ne $i)
                }
                # return the item
                return $_
            } else {

            }

            if(-not $i){
                return $_
            }
        }
    }
} Export-ModuleMember -Function Find-NotInProject -Alias "wsp","Where-SalesProject"