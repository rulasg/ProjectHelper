function Invoke-UpdateItem{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $Owner,
        [Parameter(Mandatory)][string] $ProjectNumber,
        [Parameter(Mandatory)][string] $dbId,
        [Parameter(Mandatory)][hashtable] $fieldValue
    )


    $body = fromFieldsToInput -fieldValue $fieldValue

    $params = @{
        Api = "/orgs/$Owner/projectsV2/$ProjectNumber/items/$dbId"
        Method = "PATCH"
        Body = $body
    }

    "Calling Invoke-RestAPI with params:" | Write-MyDebug -Section "UpdateItem" -object $params

    $response = Invoke-RestAPI @params

    return $response
} Export-ModuleMember -Function Invoke-UpdateItem

function fromFieldsToInput{
    param(
        [hashtable]$fieldValue
    )

    $fields = @()
    foreach($key in $fieldValue.Keys) {
        $fields += @{
            id = $key
            value = $fieldValue[$key]
        }
    }

    $ret = @{
        fields = $fields
    }

    return $ret
} Export-ModuleMember -Function fromFieldsToInput