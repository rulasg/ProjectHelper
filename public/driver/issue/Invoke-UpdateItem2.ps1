
# Sample execution
#
# $n = [pscustomobject] @{id= "220956213"; value = 71 ; type = "NUMBER"}
# $t = [pscustomobject] @{id= "220956234"; value = "text 71" ; type = "TEXT"}
# $b64 = @($n,$t)  | ConvertTo-Json | ConvertTo-Base64
# invoke-UpdateItem2 -Owner octodemo -ProjectNumber 700 -dbId 135630152 -fieldValueBase64 $b64

function Invoke-UpdateItem2{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $Owner,
        [Parameter(Mandatory)][string] $ProjectNumber,
        [Parameter(Mandatory)][string] $dbId,
        [Parameter(Mandatory)][string] $fieldValueBase64
    )


    $body = fromFieldsToInput2 $fieldValueBase64

    $params = @{
        Api = "/orgs/$Owner/projectsV2/$ProjectNumber/items/$dbId"
        Method = "PATCH"
        Body = $body
    }

    "Calling Invoke-RestAPI with params:" | Write-MyDebug -Section "UpdateItem" -object $params

    $response = Invoke-RestAPI @params

    return $response
} Export-ModuleMember -Function Invoke-UpdateItem2

function fromFieldsToInput2{
    param(
        [string]$fieldValueBase64
    )

    $fieldValue = $fieldValueBase64 | ConvertFrom-Base64 | ConvertFrom-Json -AsHashtable

    $fields = @()
    foreach($f in $fieldValue) {

        $field = @{id = [int]$f.id}
        
        switch($f.type){
            "TEXT"   { $field.value = [string]$f.value }
            "NUMBER" { $field.value = [int32]$f.value }

            default {
                $field.value = [string]$f.value
            }
        }

        $fields += $field
    }

    $ret = @{
        fields = $fields
    }

    return $ret
} Export-ModuleMember -Function fromFieldsToInput2