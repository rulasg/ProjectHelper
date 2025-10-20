
Set-MyInvokeCommandAlias -Alias GetRepository -Command "Invoke-Repository -Owner {owner} -Name {name}"

function Get-Repository{
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][switch]$Force
    )

    # Check database
    $key = "$Owner-$Name"
    $repodb = Get-Database -Key $key

    # use cache if available and not forced
    if( $repodb -and (! $Force) ){
         # Get repository from GitHub
         return $repodb
    }

    $params = @{
        owner = $Owner
        name  = $Name
    }
    $response = Invoke-MyCommand GetRepository $params

    $repo = $response.data.repository

    if(-Not $repo){
        throw "Repository $Owner/$Name not found"
    }

    # Transformations
    $repo.owner = $repo.owner.login
    # This parent comes from the query justin case the repo is a fork show the parent where to crete issues.
    # We will ignore this by the moment as we do not use forks normally
    $repo.PSObject.Properties.Remove('parent')

    $ret = $repo

    # Save to database
    Save-Database -Key $key -Database $ret

    return $ret

} Export-ModuleMember -Function Get-Repository