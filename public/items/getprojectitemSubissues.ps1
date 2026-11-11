function Get-ProjectItemSubissues{
    [CmdletBinding()]
    [Alias("gpis")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 0)][Alias("id")][string]$ItemId,
        [Parameter()][switch]$PassThru

    )

    process {

        $itemId = [string]::IsNullOrWhiteSpace($ItemId) ? $(Invoke-QQ_Get_G) : $ItemId

        ($Owner,$ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

        $item = Resolve-ItemParameter -Owner $Owner -ProjectNumber $ProjectNumber -IdOrUrl $itemId

        if(-not $item){
            throw "SubIssue not found"
        }

        if($item.subIssues.Count -eq 0){
            return @()
        }

        $ret = @()
        $item.subIssues | ForEach-Object {
            $subissue = Get-ProjectitemByUrl -Owner $Owner -ProjectNumber $ProjectNumber -url $_.url -PassThru
            if($subissue){
                $ret += $subissue
            } else {
                "Subissue not found in project [$owner/$ProjectNumber] $($_.Url)" | Write-Debug -section "Get-ProjectItemSubissues"
            }
        }

        if(-not $PassThru){

            $ret = @( $ret | foreach-object {
                [pscustomobject]@{
                    Id = $_.id
                    Title = $_.Title
                    Url = $_.url
                }
            })
        }

        return $ret
    }
} Export-ModuleMember -Function Get-ProjectItemSubissues -Alias "gpis"