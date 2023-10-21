function New-Issue{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("nghi")]
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Title,
        [Parameter()][string]$Body
    )

    begin{}

    process{

        # Get default values from Environment
        $Repo = Resolve-EnvironmentRepo -Repo $Repo ; if(!$Repo){return $null}

        # Build expression
        $expressionPattern = 'gh issue create --repo "{0}" --title "{1}" --body "{2}"'
        $command = $expressionPattern -f $Repo,$Title,$Body

        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpression -Command $command
        } else {
            # For Testing
            $command | Write-Information
            $result = 'https://githubInstance.com/someOwner/someRepo/issues/6'
        }

        # Check if its a url
        $success = Test-NewIssueResult -Result $result -Repo $Repo 

        # Error checking
        if(!$success){
            "Error [{0}] calling gh expression [{1}]" -f $result, $command | Write-Error
            return $null
        }

        # Return issue URL
        return $result
    }
} Export-ModuleMember -Function New-Issue -Alias nghi

function Test-NewIssueResult{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Result,
        [Parameter(Mandatory)][string]$Repo
    )

    begin{}
    
    process{
        try{
            $processing = $result

            # Split repo
            $repoSplit = $repo -split "/"
            $repoOwner = $repoSplit[0]
            $repoName = $repoSplit[1]

            # Remove the numbrer
            $processing = $processing | Split-Path -parent 

            #Isse
            ($processing | Split-Path -leaf) -eq "issues" | Assert -Message "Expected 'issues' in path: $processing"

            $processing = $processing | Split-Path -parent 
            
            # Repo Name
            ($processing | Split-Path -leaf) -eq $repoName | Assert -Message "Expected '$repoName' in path: $processing"
            
            $processing = $processing | Split-Path -parent 

            #Repo Owner
            ($processing | Split-Path -leaf) -eq $repoOwner | Assert -Message "Expected '$repoOwner' in path: $processing"

        } catch {
            "Error: {0}" -f $_.Exception.Message | Write-Error
            return $false
        }

        return $true
    }
}

function Assert{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][bool]$condition,
        [Parameter()][string]$Message
    )

    process{
        if(!$condition){
            # $Message | Write-Error
            throw $Message
        }
    }
}

function Get-Issues{
    [CmdletBinding()]
    [Alias("gghi")]
    param(
        [Parameter()][string]$Repo
    )

#   USAGE
#   gh issue list [flags]
#
#     FLAGS
#       --app string         Filter by GitHub App author
#   -a, --assignee string    Filter by assignee
#   -A, --author string      Filter by author
#   -q, --jq expression      Filter JSON output using a jq expression
#       --json fields        Output JSON with the specified fields
#   -l, --label strings      Filter by label
#   -L, --limit int          Maximum number of issues to fetch (default 30)
#       --mention string     Filter by mention
#   -m, --milestone string   Filter by milestone number or title
#   -S, --search query       Search issues with query
#   -s, --state string       Filter by state: {open|closed|all} (default "open")
#   -t, --template string    Format JSON output using a Go template; see "gh help formatting"
#   -w, --web                List issues in the web browser

    process {
        # Environment
        $Repo = Resolve-EnvironmentRepo -Repo $Repo ; if(!$Repo){return $null}

        # Build expression
        # $expressionPattern = 'gh issue list --repo {0} --json number,title,state,url'
        # $command = $expressionPattern -f $Repo

        $command = Build-Command Issue_List $Repo

        # Invoke Expresion
        $result = Invoke-GhExpressionToJson -Command $command

        # # Check output success
        # $success = Test-IssueList -Result $result

        # # Error checking
        # if(!$success){
        #     "Error [{0}] calling gh expression [{1}]" -f $result, $command | Write-Error
        #     return $null
        # }

        # Transform
        # So far no transformation needed
        # $ret = $result | ConvertFrom-Json

        # Return issues
        return $result
    }
} Export-ModuleMember -Function Get-Issues -Alias gghi

function Test-IssueList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Result
    )

    return $true
}