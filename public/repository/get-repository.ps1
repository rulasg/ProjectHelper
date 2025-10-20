
Set-MyInvokeCommandAlias -Alias GetRepository -Command "Invoke-Repository -Owner {owner} -Name {name}"

function Get-Repository{
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Name
    )

    $params = @{
        owner = $Owner
        name  = $Name
    }
    $response = Invoke-MyCommand GetRepository $params

    $repo = $response.data.repository

    if(-Not $repo){
        throw "Repository $Owner/$Name not found"
    }

    $repo.owner = $repo.owner.login

    $ret = $repo

    return $ret

} Export-ModuleMember -Function Get-Repository