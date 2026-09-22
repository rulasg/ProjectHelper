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

            # $i = [string]::IsNullOrWhiteSpace($url) ? $null : $(Get-ProjectItemByUrl -Owner $Owner -ProjectNumber $ProjectNumber -Url $url -ErrorAction SilentlyContinue)
            $isMember = Test-ProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -Url $url -ErrorAction SilentlyContinue

            # Add $fieldname to the input Item based on type 
            if($All){
                if($_ -is [hashtable]){
                    $_[$fildname] = $isMember
                } else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name $fildname -Value $isMember
                }
                # return the item
                return $_
            }

            # If not $All, return only items that are not in the project
            if(-not $isMember){
                return $_
            }
        }
    }
} Export-ModuleMember -Function Find-NotInProject -Alias "wsp","Where-SalesProject"