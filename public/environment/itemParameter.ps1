function Resolve-ItemParameter{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$ProjectNumber,
        [Parameter(Mandatory)][string]$IdOrUrl
    )

    if(Test-Url -Url $IdOrUrl){
        $ret = Get-ProjectItemByUrl -Owner $Owner -ProjectNumber $ProjectNumber -Url $IdOrUrl -PassThru
    }
    else{
        $ret = Get-BaseProjectItem -Owner $Owner -ProjectNumber $ProjectNumber -ItemId $IdOrUrl
    }

    if(-not $ret){
        "Identifier [$IdOrUrl] could not be resolved." | Write-MyDebug -section 'Resolve-ItemParameter'
        return $null
    }

    "Identifier [$IdOrUrl] : $($ret.Id)" | Write-MyDebug -section 'Resolve-ItemParameter'

    return $ret
}