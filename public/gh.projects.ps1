

function New-GhPItem{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("nghpd")]
    param(
        [Parameter()][string]$ProjectTitle,
        [Parameter()][string]$Owner,
        [Parameter(Mandatory,Position=0)][string]$Title,
        [Parameter(Position=1)][string]$Body
    )

    begin{}

    process{
        $env = Resolve-GhPEnviroment -Owner $Owner -ProjectTitle $ProjectTitle ; if(!$env){return $null}
        # Get default values from Environment
        # $Owner = Find-GhPOwnerFromEnvironment -Owner $Owner ; if(!$Owner){return $null}
        # $ProjectTitle = Find-GhProjectTitleFromEnvironment($ProjectTitle) ; if(!$ProjectTitle){return $null}
        # $ProjectNumber = Get-GhProjectNumber -ProjectTitle $ProjectTitle -Owner $Owner ; if($ProjectNumber -eq -1){return $null}

        # Build expression
        $expressionPattern_Item_Create = "gh project item-create {0} --owner `"{1}`" --title `"{2}`" --body `"{3}`""
        $command = $expressionPattern_Item_Create -f $env.ProjectNumber, $env.Owner, $Title, $Body

        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpression -Command $command
        } else {
            $command | Write-Information
            $result = $null
        }

        # Error checking
        if($null -ne $result){
            "Error [{0}] calling gh expression [{1}]" -f $result, $command | Write-Error
            return
        }
    }
} Export-ModuleMember -Function New-GhPItem -Alias nghpd

function Get-GhProjectNumber{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    [Alias("gghpn")]
    param(
        [Parameter(Mandatory)][string]$ProjectTitle,
        [Parameter(Mandatory)][string]$Owner,
        [Parameter()][switch]$Force
    )
    
    # Build expression
    $expressionPattern_Project_List = 'gh project list --owner "{0}" --limit 1000 --format json'
    $command = $expressionPattern_Project_List -f $Owner

    if ($PSCmdlet.ShouldProcess("GitHub Cli", $command)) {

        # list projects on account
        $result =  Invoke-GhExpression -Command $command | ConvertFrom-Json

        "[{0}] projects found" -f $result.projects.Count | Write-Verbose

        # check if $reusult is empty
        if($null -eq $result.projects){
            Write-Error "No projects found for OWNER [$Owner]"
            return -1
        }
    
        [int]$projectNumber = $result.projects | Where-Object {$_.Title -Like $ProjectTitle} | Select-Object -ExpandProperty number

        if($null -eq $projectNumber){
            "No project found with TITLE [$ProjectTitle] for OWNER [$Owner]" | Write-Error
            return -1
        }
        
    } else {
        # for testing
        $command | Write-Information
        $projectNumber = 666 # Fake number for testing
    }

    return $projectNumber
}

function Get-GhProjects{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("gghp")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$Title,
        [Parameter()][switch]$Details
    )

    # Build Command
    $expressionPattern_Project_List = 'gh project list --limit 1000 --format json'

    if($Owner){
        $expressionPattern_Project_List += ' --owner "{0}"'
        $command = $expressionPattern_Project_List -f $Owner
    } else {
        $command = $expressionPattern_Project_List
    }

    # Invoke Command
    $result = Invoke-GhExpression -Command $command | ConvertFrom-Json

    # Filter result
    if($Title){
        $filtered = @()
        $result.projects | Where-Object {$_.Title -like $Title} | ForEach-Object {
            $filtered += $_
        }
    } else {
        $filtered = $result.projects
    }

    # transform
    $ret = @()
    foreach($projectItem in $filtered){

        if ($Details){

            $project  =  [PSCustomObject]@{
                number = $projectItem.number
                url = $projectItem.url
                shortDescription = $projectItem.shortDescription
                public = $projectItem.public
                closed = $projectItem.closed
                title = $projectItem.title
                id = $projectItem.id
                readme = $projectItem.readme
                items = $projectItem.items.totalCount
                fields = $projectItem.fields.totalCount
                # owner = "{0}/{1}" -f $projectItem.owner.Type, $projectItem.owner.Login
                owner = $projectItem.owner.Login
            }
        } else {
            $project  =  [PSCustomObject]@{
                number = $projectItem.number
                # url = $projectItem.url
                # shortDescription = $projectItem.shortDescription
                # public = $projectItem.public
                # closed = $projectItem.closed
                title = $projectItem.title
                # id = $projectItem.id
                # readme = $projectItem.readme
                # items = $projectItem.items.totalCount
                # fields = $projectItem.fields.totalCount
                # owner = "{0}/{1}" -f $projectItem.owner.Type, $projectItem.owner.Login
                owner = $projectItem.owner.Login
            }
        }

        $ret += $project
    }

    return $ret

} Export-ModuleMember -Function Get-GhProjects -Alias gghp


