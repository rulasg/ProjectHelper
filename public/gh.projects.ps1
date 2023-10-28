

function New-ProjectItem{
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
        # Get default values from Environment
        $env = Resolve-EnvironmentProject -Owner $Owner -ProjectTitle $ProjectTitle ; if(!$env){return $null}

        # Build expression
        $command = Build-Command -CommandKey Project_Item_Create -Owner $env.Owner -ProjectNumber $env.ProjectNumber -Title $Title -Body $Body

        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpressionToJson -Command $command
        } else {
            $command | Write-Information
            $result = $null
        }

        # Error checking

        return $result
    }
} Export-ModuleMember -Function New-ProjectItem -Alias nghpd

function Get-ProjectNumber{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    [Alias("gghpn")]
    param(
        [Parameter(Mandatory)][string]$ProjectTitle,
        [Parameter(Mandatory)][string]$Owner,
        [Parameter()][switch]$Force
    )
    
    $command = Build-Command -CommandKey Project_List_Owner -Owner $Owner

    if ($PSCmdlet.ShouldProcess("GitHub Cli", $command)) {

        # list projects on account
        $result =  Invoke-GhExpressionToJson -Command $command

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
} Export-ModuleMember -Function Get-ProjectNumber -Alias gghpn

function Get-ProjectList{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("gghp")]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$Title,
        [Parameter()][switch]$Details
    )

    if([string]::IsNullOrWhiteSpace($owner)){
        $command = Build-Command -CommandKey Project_List
    } else {
        $command = Build-Command -CommandKey Project_List_Owner -Owner $Owner
    }

    # Invoke Command
    $result = Invoke-GhExpressionToJson -Command $command

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

} Export-ModuleMember -Function Get-ProjectList -Alias gghp


