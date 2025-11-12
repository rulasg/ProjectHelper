
Set-MyinvokeCommandAlias -Alias getUser -Command "Invoke-GetUser -Handle {handle}"
function Invoke-GetUser{
    param(
        [Parameter(Mandatory)][string]$Handle
    )

     $result = Invoke-RestAPI -Api /users/$Handle

     return $result

} Export-ModuleMember -Function Invoke-GetUser

function Get-User{
    param(
        [Parameter(Mandatory)][string]$Handle,
        [Parameter()][switch]$Force
    )

    $key = "user-$Handle"

    # Check cache
    $cache = Get-Database -Key $key
    if(-Not $Force -And ($null -ne $cache)){
        return $cache
    }

     $result = Invoke-MyCommand -Command "getUser" -Parameters @{handle=$Handle}

     # Cache
     Save-Database -Key "user-$Handle" -Database $result

     $ret = [PSCustomObject]@{
        Id = $result.node_id
        Name = $result.Name
        Email = $result.Email
        Login = $result.Login
     }

     return $ret

} Export-ModuleMember -Function Get-User